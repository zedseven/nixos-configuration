# An HP Spectre x360 Laptop - 5FP19UA.
{
  config,
  inputs,
  userInfo,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  custom = {
    user.type = "full";
    global.configurationPath = "/persist/etc/nixos";

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = [
        "/home"
        "/persist"
      ];
      extraExcludeEntries = [
        "/home/${userInfo.username}/torrents/artifacts/"
        "/home/${userInfo.username}/git/nixpkgs"
      ];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 00:00:00";
      setEnvironmentVariables = true;
    };

    darlings.persist.paths = [
      "/etc/machine-id"
      "/etc/mullvad-vpn"
      "/etc/ssh"
      "/root/.cache/restic"
      "/var/log"
    ];

    desktop = {
      enable = true;

      displays = {
        fingerprints = {
          "eDP-1" = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
        };

        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            positionX = 0;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 60;
            dpi = 192;
          };
        };
      };

      suckless.st = {
        font = {
          family = "PragmataPro Mono";
          pixelSize = 24;
          characterTweaks = {
            heightScale = 14.0 / 15.0;
            yOffset = -1;
          };
        };
        colourSchemeText = ''
          /* Terminal colors (first 16 used in escape sequence) */
          static const char *colorname[] = {
          		/* 8 normal colors */
          		"#303030", /* black   */
          		"#a43261", /* red     */
          		"#66cc99", /* green   */
          		"#006ca5", /* yellow  */
          		"#6751a6", /* blue    */
          		"#913e88", /* magenta */
          		"#0061b1", /* cyan    */
          		"#c6c6c6", /* white   */

          		/* 8 bright colors */
          		"#5e5e5e", /* black   */
          		"#ff9fc9", /* red     */
          		"#99ffcc", /* green   */
          		"#3bd6ff", /* yellow  */
          		"#d5b8ff", /* blue    */
          		"#ffa7f6", /* magenta */
          		"#93c9ff", /* cyan    */
          		"#ffffff", /* white   */

          		[255] = 0,

          		/* special colors */
          		"#cccccc",
          		"#555555",
          		"gray90", /* default foreground colour */
          		"black", /* default background colour */
          };

          /*
           * Default colors (colorname index)
           * foreground, background, cursor, reverse cursor
           */
          unsigned int defaultfg = 258;
          unsigned int defaultbg = 259;
          unsigned int defaultcs = 256;
          static unsigned int defaultrcs = 257;
        '';
      };

      displayDriver = "nvidia";
      is4k = true;
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games.ndsplus.enable = true;
    };

    symlinks = {
      "/etc/wpa_supplicant.conf".source = config.age.secrets."wpa_supplicant.conf".path;
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;
    };

    grub = {
      enable = true;
      efi.enable = true;
    };

    wireguard.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "eff5369a";
    # Networks are defined in `/etc/wpa_supplicant.conf`
    wireless.enable = true;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:59@0:0:0";
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
