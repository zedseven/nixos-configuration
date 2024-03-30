# An Oracle Cloud ARM VPS, mainly for hosting a Minecraft server.
# Named after the Gracidea, the flower of gratitude, from Pokémon.
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  custom = {
    user.type = "minimal";
    global.configurationPath = "/persist/etc/nixos";

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = [
        "/home"
        "/persist"
      ];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 02:00:00";
    };

    darlings = {
      enable = true;
      persist.paths = [
        "/etc/machine-id"
        "/etc/ssh"
      ];
    };

    grub = {
      enable = true;
      efi = {
        enable = true;
        installAsRemovable = true;
      };
    };

    zfs.enable = true;
  };

  networking.hostId = "7fed7617";

  services = {
    openssh = {
      openFirewall = true;
    };
  };

  system.stateVersion = "24.05"; # Don't touch this, ever
}
