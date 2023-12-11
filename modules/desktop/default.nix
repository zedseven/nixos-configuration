{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./suckless
  ];

  security.protectKernelImage = false; # To allow for hibernation

  services = {
    xserver = {
      enable = true;
      libinput.enable = true;
      windowManager.dwm.enable = true;
      displayManager = {
        defaultSession = "none+dwm";
        autoLogin = {
          enable = true;
          user = "zacc";
        };
      };
      desktopManager.wallpaper.mode = "fill";
      dpi = lib.mkDefault 96;
      extraConfig = ''
        # Security settings for `slock`
        Section "ServerFlags"
        	#Option "DontVTSwitch" "True"
        	Option "DontZap"      "True"
        EndSection
      '';
    };

    pcscd.enable = true;
    printing.enable = true;
    logind = {
      lidSwitch = "hybrid-sleep";
      extraConfig = ''
        HandlePowerKey=hybrid-sleep
        IdleAction=hybrid-sleep
        IdleActionSec=1m
      '';
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };

  sound = {
    enable = true;
    enableOSSEmulation = true; # Allows for `/dev/mixer`
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableSSHSupport = true;
    };
    dconf.enable = true; # Required when `gtk.enable` is set in `home-manager`: https://github.com/nix-community/home-manager/issues/3113
    light.enable = true;
    slock.enable = true;
    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.slock}/bin/slock -c";
    };
  };

  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    HibernateMode=platform shutdown
    HibernateState=disk
    HybridSleepMode=suspend platform shutdown
    HybridSleepState=disk
  '';

  # To allow file sharing over HTTP via `miniserve`
  networking.firewall = {
    allowedTCPPorts = [8080];
  };

  users.users.zacc = {
    extraGroups = [
      "audio"
      "video"
    ];
    # GUI packages
    packages = with pkgs;
      [
        dmenu
        firefox-devedition
        jetbrains.clion
        jetbrains.rust-rover
        keepass
        obsidian
        slstatus
        st
      ]
      ++ [
        (pkgs.writeShellScriptBin "shutdown-now" ''
          shutdown -h now
        '')
      ];
  };
  home-manager.users.zacc = {
    imports = [
      ./discord
    ];

    xsession = {
      enable = true;
      profileExtra = ''
        slstatus &
        slock &
      '';
    };

    # Required so that cursor settings are applied for GTK applications
    gtk.enable = true;

    home.pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = lib.mkDefault 32;
      x11.enable = true;
      gtk.enable = true;
    };

    xresources.properties = lib.mkDefault {
      "Xft.dpi" = 96;
    };

    services.sxhkd = {
      enable = true;
      keybindings = {
        "XF86AudioRaiseVolume" = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
        "XF86AudioLowerVolume" = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
        "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86MonBrightnessUp" = "light -A 5";
        "XF86MonBrightnessDown" = "light -U 5";
      };
    };

    programs.discord = {
      enable = true;
      wrapDiscord = true;
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    discord = pkgs.discord.overrideAttrs {
      withOpenASAR = true;
    };
  };
}
