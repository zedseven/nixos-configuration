# My main PC.
{
  config,
  home-manager,
  userInfo,
  ...
}: let
  configPath = "/persist/etc/nixos";
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
    ../../user.nix
  ];

  custom = {
    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = ["/home" "/persist"];
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
    };

    darlings = {
      enable = true;
      persist.paths = [
        "/etc/mullvad-vpn"
        "/etc/ssh"
        "/var/lib/bluetooth"
      ];
    };

    desktop = {
      enable = true;
      displayDriver = "nvidia";
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      bluetooth.enable = true;
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games.enable = true;
    };

    symlinks = {
      "/etc/nixos".source = configPath;
      "/etc/wpa_supplicant.conf".source = config.age.secrets."wpa_supplicant.conf".path;
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;
    };

    physical.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "c4f086eb";
    # Networks are defined in `/etc/wpa_supplicant.conf`
    wireless.enable = true;
  };

  home-manager.users.${userInfo.username}.programs.autorandr.profiles = {
    "home" = {
      # The easiest way to obtain the fingerprints is to run `autorandr --fingerprint`
      fingerprint = {
        "DP-0" = "00ffffffffffff001e6dfa761ae10400081c0104a55022789eca95a6554ea1260f5054256b807140818081c0a9c0b300d1c08100d1cfcd4600a0a0381f4030203a001e4e3100001a003a801871382d40582c4500132a2100001e000000fd00384b1e5a18000a202020202020000000fc004c4720554c545241574944450a0126020314712309060747100403011f1312830100008c0ad08a20e02d10103e96001e4e31000018295900a0a038274030203a001e4e3100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae";
        "HDMI-0" = "00ffffffffffff004c2d5c0c4b484d302a190103803c22782a5295a556549d250e505423080081c0810081809500a9c0b30001010101023a801871382d40582c450056502100001e011d007251d01e206e28550056502100001e000000fd00323c1e5111000a202020202020000000fc00533237453539300a202020202001af02031af14690041f130312230907078301000066030c00100080011d00bc52d01e20b828554056502100001e8c0ad090204031200c4055005650210000188c0ad08a20e02d10103e9600565021000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061";
      };
      config = {
        "DP-0" = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "2560x1080";
          rate = "74.99";
          dpi = 96;
        };
        "HDMI-0" = {
          enable = true;
          position = "2560x0";
          mode = "1920x1080";
          rate = "60.00";
          dpi = 96;
        };
      };
    };
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
