# The private VPN host node, connecting everything else.
{
  config,
  inputs,
  hostname,
  system,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  custom = {
    user.type = "minimal";

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
      scheduled.onCalendar = "*-*-* 01:30:00";
    };

    darlings = {
      enable = true;
      persist.paths = [
        "/etc/machine-id"
        "/etc/ssh"
      ];
    };

    grub.enable = true;
    zfs.enable = true;
  };

  networking.hostId = "edbeca50";

  services.openssh = {
    openFirewall = true;
    ports = [inputs.private.unencryptedValues.serverPorts.${hostname}.ssh];
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
