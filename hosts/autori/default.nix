# The main server for hosting web services, among other things.
{
  config,
  inputs,
  hostname,
  userInfo,
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
    global.configurationPath = "/persist/etc/nixos";

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = ["/home" "/persist"];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 01:00:00";
    };

    darlings = {
      enable = true;
      persist.paths = [
        "/etc/machine-id"
        "/etc/ssh"
        "/var/lib/acme"
      ];
    };

    grub.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "0824a9c7";
    firewall.allowedTCPPorts = [80 443];
  };

  services.openssh = {
    openFirewall = true;
    ports = inputs.private.unencryptedValues.serverPorts.${hostname}.ssh;
  };

  services.nginx = {
    enable = true;
    virtualHosts."ztdp.ca" = {
      enableACME = true;
      forceSSL = true;
      root = "${inputs.website-ztdp.packages.${system}.default}";
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = userInfo.email;
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
