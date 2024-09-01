# The private VPN host node, connecting everything else.
{
  config,
  inputs,
  hostname,
  system,
  ...
}: let
  forgejoDir = "/var/lib/forgejo";
in {
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
        "/var/log"
        forgejoDir
      ];
    };

    grub.enable = true;
    wireguard.enable = true;
    zfs.enable = true;
  };

  networking = let
    interface = "enp1s0";
    hetzner = import ../../constants/hetzner.nix;
  in {
    hostId = "edbeca50";

    # This is required due to a known IPv6 issue with Hetzner
    # https://docs.hetzner.com/cloud/servers/static-configuration/
    # https://docs.hetzner.com/cloud/servers/primary-ips/primary-ip-configuration/
    # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/3
    interfaces.${interface} = {
      ipv6.addresses = [inputs.private.unencryptedValues.serverAddresses.${hostname}.ipv6];
    };
    defaultGateway6 = {
      inherit interface;
      address = hetzner.gatewayAddresses.ipv6;
    };
  };

  services = {
    openssh = {
      openFirewall = true;
      ports = [inputs.private.unencryptedValues.serverPorts.${hostname}.ssh];
    };

    forgejo = {
      enable = true;
      stateDir = "/persist" + forgejoDir;
    };
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
