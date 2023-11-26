# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
let
  private = import ./private;
in
  {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix # Include the results of the hardware scan.
      <home-manager/nixos>
    ];

    nixpkgs.config.allowUnfree = true;

    # Use the systemd-boot EFI boot loader.
    # boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.supportedFilesystems = ["zfs"];

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
    };

    # Wipe the root directory on boot
    # NixOS will rebuild it every time, giving the system a "new computer feel" on every boot
    # This also tests the system's ability to build from scratch
    # https://grahamc.com/blog/erase-your-darlings/
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    environment = {
      etc."nixos".source = "/home/zacc/nix";
      etc."mullvad-vpn".source = "/persist/etc/mullvad-vpn";
    };

    networking.hostName = "wraith"; # Define your hostname.
    networking.hostId = "eff5369a";
    # Pick only one of the below networking options.
    networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
    networking.wireless.networks = private.networks;
    #    networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

    # Set your time zone.
    time.timeZone = "America/Toronto";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_CA.utf8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkbOptions in tty.
    # };

    security.protectKernelImage = false; # To allow for hibernation
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=15
    '';

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      dpi = 192;
      libinput.enable = true;
      windowManager.dwm.enable = true;
      windowManager.dwm.package = pkgs.dwm.overrideAttrs {
        src = /home/zacc/suckless/dwm;
      };
      displayManager = {
        defaultSession = "none+dwm";
        autoLogin = {
          enable = true;
          user = "zacc";
        };
      };
      desktopManager.wallpaper.mode = "fill";
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:59@0:0:0";
      };
    };

    # Configure keymap in X11
    # services.xserver.layout = "us";
    # services.xserver.xkbOptions = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableSSHSupport = true;
    };

    # Enable sound.
    sound.enable = true;
    sound.enableOSSEmulation = true; # Allows for `/dev/mixer`
    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.support32Bit = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.zacc = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "audio"
        "video"
      ];
      packages = with pkgs; [
        alejandra
        bottom
        du-dust
        eza
        fd
        file
        firefox-devedition
        gcc
        git
        gnumake
        home-manager
        jetbrains.clion
        jetbrains.rust-rover
        keepass
        libfaketime
        miniserve
        neofetch
        obsidian
        plantuml
        procs
        rclone
        restic
        ripgrep
        rustup
        tree
        viu
        (tealdeer.overrideAttrs (drv: rec {
          src = fetchFromGitHub {
            owner = "zedseven"; # Until https://github.com/dbrgn/tealdeer/issues/320 is resolved
            repo = "tealdeer";
            rev = "3cf0e51dda80bf7daa487085cedd295920bbaf55";
            sha256 = "sha256-G/GOy0Imdd9peFbcDXqv+IKZc0nYszBY0Dk4DbbULAA=";
          };
          doCheck = false;
          cargoDeps = drv.cargoDeps.overrideAttrs {
            inherit src;
            outputHash = "sha256-ULIBSuCyr5naXhsQVCR2/Z0WY3av5rbbg5l30TCjHDY=";
          };
        }))
        (dmenu.overrideAttrs {
          src = /home/zacc/suckless/dmenu;
        })
        (slstatus.overrideAttrs {
          src = /home/zacc/suckless/slstatus;
        })
        (st.overrideAttrs (oldAttrs: rec {
          buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
          src = /home/zacc/suckless/st;
        }))
      ];
      hashedPassword = private.hashedPassword;
      shell = pkgs.fish;
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.zacc = import ./home.nix;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      killall
      lshw
      lsof
      pciutils
      unzip
      vim
      wget
    ];
    environment.shells = with pkgs; [fish];

    # Required because `programs.slock` has no option to override the package easily
    nixpkgs.config.packageOverrides = pkgs: {
      slock = pkgs.slock.overrideAttrs {
        src = /home/zacc/suckless/slock;
      };
    };

    programs.light.enable = true;

    programs.slock.enable = true;
    programs.xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.slock}/bin/slock -c";
    };

    services.logind = {
      lidSwitch = "hybrid-sleep";
      extraConfig = ''
        HandlePowerKey=hybrid-sleep
        IdleAction=hybrid-sleep
        IdleActionSec=1m
      '';
    };

    systemd.sleep.extraConfig = ''
      AllowHibernation=yes
      HibernateMode=platform shutdown
      HibernateState=disk
      HybridSleepMode=suspend platform shutdown
      HybridSleepState=disk
    '';

    programs.fish.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;
    services.zfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    system.copySystemConfiguration = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  }
