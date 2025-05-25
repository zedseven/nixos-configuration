# An Oracle Cloud ARM VPS, mainly for hosting a Minecraft server.
# Named after the Gracidea, the flower of gratitude, from Pokémon.
{
  config,
  lib,
  inputs,
  hostname,
  system,
  ...
}: let
  minecraftDir = "/var/lib/minecraft";
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  # Impermanence
  environment.persistence.${config.custom.darlings.persist.mirrorRoot} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/ssh"
      "/root/.cache/restic"
      "/var/lib/nixos"
      "/var/log"
      minecraftDir
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  custom = {
    user.type = "minimal";
    darlings.persist.ageIdentityPaths.enable = true;

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

    grub = {
      enable = true;
      efi = {
        enable = true;
        installAsRemovable = true;
      };
    };

    wireguard.enable = true;
    zfs.enable = true;

    desktop.games.minecraft = {
      enable = true;
      server = {
        enable = true;

        package = inputs.self.packages.${system}.minecraft-server-fabric;
        dataDir = "/persist" + minecraftDir;
        memoryAllocatedGigabytes = 22;
        aikarsFlags = true;
        port = inputs.private.unencryptedValues.serverPorts.${hostname}.minecraft;

        whitelistFile = config.age.secrets."minecraft-server-whitelist.json".path;
        operatorsFile = config.age.secrets."minecraft-server-ops.json".path;
        iconFile = let
          fileName = "gracidea.png";
          storePath = lib.fileset.toSource {
            root = ./.;
            fileset = ./. + "/${fileName}";
          };
        in "${storePath}/${fileName}";

        serverProperties = {
          allow-flight = true;
          difficulty = "hard";
          enable-command-block = true;
          level-name = "grove";
          max-players = 10;
          motd = "\\u00a72*\\u00a7dx\\u00a7a+\\u00a7f Gracidea \\u00a7a+\\u00a7dx\\u00a72*";
          spawn-protection = 0;
          view-distance = 12;
        };

        mods = builtins.attrValues {
          inherit
            (inputs.self.legacyPackages.${system}.minecraftFabricMods)
            aether
            almanac
            appleskin
            c2me
            carpet
            carpet-extra
            clumps
            convenient-mobgriefing
            fabric-api
            ferrite-core
            krypton
            let-me-despawn
            lithium
            memory-leak-fix
            mixin-trace
            noisium
            owo-lib
            servux
            stitched-snow
            ;
        };
      };
    };
  };

  networking.hostId = "7fed7617";

  services.openssh = {
    openFirewall = true;
    ports = [inputs.private.unencryptedValues.serverPorts.${hostname}.ssh];
  };

  system.stateVersion = "24.05"; # Don't touch this, ever
}
