{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  system,
  ...
}: let
  cfg = config.custom.desktop;
in {
  imports = [
    ./display-drivers
    ./suckless
    ./4k.nix
    ./audio.nix
    ./bluetooth.nix
    ./printing.nix
    ./discord
    ./games
    ./calibre.nix
    ./stenography.nix
  ];

  options.custom.desktop = with lib; {
    enable = mkEnableOption "customisations for desktop devices";
    displays = {
      fingerprints = mkOption {
        description = ''
          Output name to EDID mapping.
          The easiest way to obtain the fingerprints is to run `autorandr --fingerprint`.
        '';
        type = types.attrsOf types.str;
      };

      config = let
        # Mostly ripped from https://github.com/nix-community/home-manager/blob/b3d5ea65d88d67d4ec578ed11d4d2d51e3de525e/modules/programs/autorandr.nix#L50
        configModule = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              description = "Whether to enable the output.";
              default = true;
            };

            crtc = mkOption {
              type = types.nullOr types.ints.unsigned;
              description = "Output video display controller.";
              default = null;
              example = 0;
            };

            primary = mkOption {
              type = types.bool;
              description = "Whether output should be marked as primary.";
              default = false;
            };

            positionX = mkOption {
              type = types.int;
              description = "Output position on the X-axis.";
              example = "5760";
            };

            positionY = mkOption {
              type = types.int;
              description = "Output position on the Y-axis.";
              example = "0";
            };

            resolutionX = mkOption {
              type = types.ints.unsigned;
              description = "Output resolution on the X-axis.";
              example = "3840";
            };

            resolutionY = mkOption {
              type = types.ints.unsigned;
              description = "Output resolution on the Y-axis.";
              example = "2160";
            };

            rate = mkOption {
              type = types.ints.unsigned;
              description = "Output framerate.";
              example = "60";
            };

            gamma = mkOption {
              type = types.str;
              description = "Output gamma configuration.";
              default = "";
              example = "1.0:0.909:0.833";
            };

            rotate = mkOption {
              type = types.nullOr (
                types.enum [
                  "normal"
                  "left"
                  "right"
                  "inverted"
                ]
              );
              description = "Output rotate configuration.";
              default = null;
              example = "left";
            };

            dpi = mkOption {
              type = types.nullOr types.ints.positive;
              description = "Output DPI configuration.";
              default = null;
              example = 96;
            };

            scale = mkOption {
              type = types.nullOr (
                types.submodule {
                  options = {
                    method = mkOption {
                      type = types.enum [
                        "factor"
                        "pixel"
                      ];
                      description = "Output scaling method.";
                      default = "factor";
                      example = "pixel";
                    };

                    x = mkOption {
                      type = types.either types.float types.ints.positive;
                      description = "Horizontal scaling factor/pixels.";
                    };

                    y = mkOption {
                      type = types.either types.float types.ints.positive;
                      description = "Vertical scaling factor/pixels.";
                    };
                  };
                }
              );
              description = ''
                Output scale configuration.

                Either configure by pixels or a scaling factor. When using pixel method the
                {manpage}`xrandr(1)`
                option
                `--scale-from`
                will be used; when using factor method the option
                `--scale`
                will be used.

                This option is a shortcut version of the transform option and they are mutually
                exclusive.
              '';
              default = null;
              example = literalExpression ''
                {
                  x = 1.25;
                  y = 1.25;
                }
              '';
            };

            filter = mkOption {
              type = types.nullOr (
                types.enum [
                  "bilinear"
                  "nearest"
                ]
              );
              description = "Interpolation method to be used for scaling the output.";
              default = null;
              example = "nearest";
            };

            adaptiveSync = mkOption {
              type = types.bool;
              description = "Whether Adaptive Sync (G-Sync or FreeSync) should be enabled for the display.";
              default = false;
            };
          };
        };
      in
        mkOption {
          description = "Per-output profile configuration.";
          type = types.attrsOf configModule;
        };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [
        "boot.shell_on_fail"
        "splash"
      ];
      loader = {
        grub = let
          primaryDisplay = builtins.head (
            builtins.filter (display: display.primary == true) (builtins.attrValues cfg.displays.config)
          );
          primaryResolution = "${(builtins.toString primaryDisplay.resolutionX)}x${(builtins.toString primaryDisplay.resolutionY)}";
        in {
          gfxmodeBios = "${primaryResolution},auto";
          gfxmodeEfi = "${primaryResolution},auto";
          gfxpayloadBios = "keep";
        };
        timeout = 0; # Hide the bootloader list unless any key is pressed
      };
      plymouth = let
        # https://github.com/adi1090x/plymouth-themes/blob/master/README.md
        # Themes I like:
        # - Angular Alt: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/5.gif
        # - Colourful Sliced: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/15.gif
        # - Cuts: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/19.gif
        # - Lone: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/53.gif
        # - Pixels: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/59.gif
        # - Rings 2: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/63.gif
        # - Sphere: https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/70.gif
        theme = "sphere";
      in {
        enable = true;
        theme = lib.mkForce theme;
        themePackages = [
          (pkgs.adi1090x-plymouth-themes.override {
            selected_themes = [theme];
          })
        ];
      };
    };

    security = {
      protectKernelImage = false; # To allow for hibernation
      rtkit.enable = true; # Used by PipeWire to acquire realtime priority
    };

    services = {
      xserver = {
        enable = true;
        windowManager.dwm.enable = true;
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

      libinput.enable = true;

      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };

      displayManager = {
        defaultSession = "none+dwm";
        autoLogin = {
          enable = true;
          user = userInfo.username;
        };
      };

      pcscd.enable = true;
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

      gnome.gnome-keyring.enable = true;

      openssh.settings.X11Forwarding = true;
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    programs = {
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      dconf.enable = true; # Required when `gtk.enable` is set in `home-manager`: https://github.com/nix-community/home-manager/issues/3113
      light.enable = true;
      slock.enable = true;
      xss-lock = {
        enable = true;
        lockerCommand = "${config.security.wrapperDir}/slock -c";
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
    networking.firewall.allowedTCPPorts = [8080];

    fonts.packages = with pkgs;
      [intel-one-mono]
      ++ (builtins.attrValues {inherit (inputs.self.packages.${system}) dank-mono pragmatapro;});

    # Add the UI programs enabled through this module as high-priority programs
    custom.desktop.suckless.dwm.highPriorityPrograms = [
      "autorandr-change"
      "clion"
      "firefox-devedition"
      "keepass"
      "mullvad-vpn"
      "obsidian"
      "reboot"
      "rust-rover"
      "shutdown-now"
      "slock"
      "xrandr-auto"
    ];

    users.users.${userInfo.username} = {
      extraGroups = [
        "audio"
        "video"
      ];
      packages = with pkgs;
        [
          inputs.self.packages.${system}.breeze
          dmenu
          firefox-devedition
          flameshot # For taking screenshots
          jetbrains.clion
          jetbrains.rust-rover
          (keepass.override {
            plugins =
              [
                keepass-keepassrpc
                keepass-keetraytotp
              ]
              ++ (builtins.attrValues {
                inherit
                  (inputs.self.legacyPackages.${system}.keepassPlugins)
                  keetheme
                  patternpass
                  yet-another-favicon-downloader
                  ;
              });
          })
          miniserve # For sharing files on the network easily
          mpv # Media player
          obsidian # Notetaking app
          pulseaudio # To get `pactl` despite using PipeWire
          seahorse # For GPG keystore management
          slstatus
          st
        ]
        ++ [
          (pkgs.writeShellScriptBin "shutdown-now" ''
            ${pkgs.systemd}/bin/shutdown -h now
          '')
          (pkgs.writeShellScriptBin "autorandr-change" ''
            ${pkgs.autorandr}/bin/autorandr --change
          '')
          (pkgs.writeShellScriptBin "xrandr-auto" ''
            ${pkgs.xorg.xrandr}/bin/xrandr --auto
          '')
          (pkgs.writeShellScriptBin "screenshot" ''
            ${pkgs.flameshot}/bin/flameshot gui --path ~/pictures/screenshots
          '')
        ];
    };

    home-manager.users.${userInfo.username} = {
      xsession = {
        enable = true;
        # These use the entries from `pkgs` despite existing as custom packages because
        # the ones in `pkgs` are overridden with the configuration for the system
        profileExtra =
          ''
            ${pkgs.slstatus}/bin/slstatus &
          ''
          # If there's no full-disk encryption, launch `slock` on startup
          + (lib.optionalString (builtins.length (builtins.attrNames config.boot.initrd.luks.devices) == 0) ''
            ${config.security.wrapperDir}/slock &
          '');
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

      xresources.properties = lib.mkDefault {"Xft.dpi" = 96;};

      programs.autorandr = {
        enable = true;

        profiles = {
          "home" = {
            fingerprint = cfg.displays.fingerprints;

            config =
              builtins.mapAttrs (_: config: {
                inherit
                  (config)
                  enable
                  crtc
                  primary
                  gamma
                  rotate
                  dpi
                  scale
                  filter
                  ;

                position = "${(builtins.toString config.positionX)}x${(builtins.toString config.positionY)}";
                mode = "${(builtins.toString config.resolutionX)}x${(builtins.toString config.resolutionY)}";
                rate = "${(builtins.toString config.rate)}.00";
              })
              cfg.displays.config;
          };
        };
      };

      services = {
        autorandr.enable = true;

        sxhkd = {
          enable = true;
          keybindings = {
            "XF86AudioRaiseVolume" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +2%";
            "XF86AudioLowerVolume" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -2%";
            "XF86AudioMute" = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86MonBrightnessUp" = "${pkgs.light}/bin/light -A 5";
            "XF86MonBrightnessDown" = "${pkgs.light}/bin/light -U 5";
          };
        };
      };
    };
  };
}
