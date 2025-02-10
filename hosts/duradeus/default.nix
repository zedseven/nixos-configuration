# My main PC.
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
      "/var/lib" # Required instead of `/var/lib/bluetooth` because of https://github.com/systemd/systemd/issues/25097
      "/var/log"
    ];

    desktop = {
      enable = true;

      displays = {
        fingerprints = {
          "DP-2" = "00ffffffffffff004c2d5672473245300b220104b54628783b4ed5ae4e45aa270e505421080081c0810081809500a9c0b3000101010108e80030f2705a80b0588a00b9882100001e000000fd0c44f0ffffee010a202020202020000000fc004f6479737365792047380a2020000000ff0048434e583330313533310a20200267020334f048615f101f3f0403762309070783010000e305c0006d1a0000020f44f000048b065a0ae60605018b5a00e5018b849079565e00a0a0a0295030203500b9882100001a6fc200a0a0a0555030203500b9882100001a023a801871382d40582c4500b9882100001e000000000000000000000000000000000000000000ec70127900000301641fa00384ff0e2f02f7801f006f085900020004000fd00184ff0e2f02af8057006f08590007800900af940104ff093f017f801f009f053a000200040033e900047f0717016b801f003704320002000400037400047f07170157802b0037042c0003800400000000000000000000000000000000000000bf90";
          "DP-4" = "00ffffffffffff004c2d5672473245300b220104b54628783b4ed5ae4e45aa270e505421080081c0810081809500a9c0b3000101010108e80030f2705a80b0588a00b9882100001e000000fd0c44f0ffffee010a202020202020000000fc004f6479737365792047380a2020000000ff0048434e583330313035300a2020026b020334f048615f101f3f0403762309070783010000e305c0006d1a0000020f44f000048b065a0ae60605018b5a00e5018b849079565e00a0a0a0295030203500b9882100001a6fc200a0a0a0555030203500b9882100001a023a801871382d40582c4500b9882100001e000000000000000000000000000000000000000000ec70127900000301641fa00384ff0e2f02f7801f006f085900020004000fd00184ff0e2f02af8057006f08590007800900af940104ff093f017f801f009f053a000200040033e900047f0717016b801f003704320002000400037400047f07170157802b0037042c0003800400000000000000000000000000000000000000bf90";
        };

        config = {
          "DP-2" = {
            enable = true;
            primary = true;
            positionX = 0;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 240;
            dpi = 144;
            adaptiveSync = true;
          };
          "DP-4" = {
            enable = true;
            positionX = 3840;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 240;
            dpi = 144;
            adaptiveSync = true;
          };
        };
      };

      displayDriver = "nvidia";
      is4k = true;
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      bluetooth.enable = true;
      calibre.enable = true;
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games = {
        steam = {
          enable = true;
          wrapSteam = true;
        };
        minecraft.enable = true;
        ndsplus.enable = true;
      };
      stenography.enable = true;
    };

    symlinks = {
      # `agenix` Values
      "/etc/wpa_supplicant.conf".source = config.age.secrets."wpa_supplicant.conf".path;
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;

      # Private Flakes
      "/etc/website-ztdp".source = "/home/${userInfo.username}/git/website-ztdp";
    };

    grub = {
      enable = true;
      efi.enable = true;
    };

    wireguard.enable = true;
    zfs.enable = true;
    qmk.enable = true;
  };

  networking = {
    hostId = "c4f086eb";
    # Networks are defined in `/etc/wpa_supplicant.conf`
    wireless.enable = true;
  };

  # To allow cross-compilation for other architectures
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  system.stateVersion = "23.05"; # Don't touch this, ever
}
