# An HP Spectre x360 Laptop - 5FP19UA.
{
  home-manager,
  userInfo,
  ...
}: let
  configPath = "/persist/etc/nixos";
  private = import /persist/etc/nixos/private;
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
      extraExcludeConfig = ''
        # Torrents
        /home/${userInfo.username}/torrents/artifacts/

        # Nixpkgs Git repo
        /home/${userInfo.username}/git/nixpkgs
      '';
      passwordSource = "/persist/etc/nixos/private/backup-passwords.sh";
      rclone = {
        enable = true;
        configPath = "/persist/etc/nixos/private/rclone.conf";
      };
      scheduled.onCalendar = "*-*-* 00:00:00";
    };

    darlings = {
      enable = true;
      persist.paths = [
        "/etc/mullvad-vpn"
      ];
    };

    desktop = {
      enable = true;
      displayDriver = "nvidia";
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      discord = {
        enable = true;
        wrapDiscord = true;
      };
    };

    symlinks = {
      "/etc/nixos".source = configPath;
    };

    physical.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "eff5369a";
    wireless = {
      enable = true;
      inherit (private) networks;
    };
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:59@0:0:0";
  };

  home-manager.users.${userInfo.username}.programs.autorandr.profiles = {
    "home" = {
      # The easiest way to obtain the fingerprints is to run `autorandr --fingerprint`
      fingerprint = {
        "eDP-1" = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
      };
      config = {
        "eDP-1" = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "3840x2160";
          rate = "60.00";
          dpi = 192;
        };
      };
    };
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
