# An Oracle Cloud ARM VPS, mainly for hosting a Minecraft server.
# Named after the Gracidea, the flower of gratitude, from Pokémon.
{
  config,
  lib,
  inputs,
  hostname,
  ...
}: let
  minecraftDir = "/var/lib/minecraft";
in {
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
        minecraftDir
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

    desktop.games.minecraft = {
      enable = true;
      server = {
        enable = true;
        dataDir = "/persist" + minecraftDir;
        jvmOpts = "-Xms512M -Xmx${builtins.toString ((24 * 1024) - 512)}M";
        port = inputs.private.unencryptedValues.serverPorts.${hostname}.minecraft;

        whitelistFile = config.age.secrets."minecraft-server-whitelist.json".path;
        iconFile = let
          fileName = "gracidea.png";
          storePath = lib.fileset.toSource {
            root = ./.;
            fileset = ./. + "/${fileName}";
          };
        in "${storePath}/${fileName}";

        serverProperties = {
          allow-flight = true;
          allow-nether = true;
          broadcast-console-to-ops = true;
          broadcast-rcon-to-ops = true;
          debug = false;
          difficulty = "hard";
          enable-command-block = true;
          enable-jmx-monitoring = false;
          enable-query = false;
          enable-rcon = false;
          enable-status = true;
          enforce-secure-profile = true;
          enforce-whitelist = true;
          entity-broadcast-range-percentage = 100;
          force-gamemode = false;
          function-permission-level = 2;
          gamemode = "survival";
          generate-structures = true;
          generator-settings = "{}";
          hardcore = false;
          hide-online-players = false;
          level-name = "grove";
          level-seed = "";
          level-type = "default";
          max-chained-neighbor-updates = 1000000;
          max-players = 10;
          max-tick-time = 300000;
          max-world-size = 29999984;
          motd = "\\u00a72*\\u00a7dx\\u00a7a+\\u00a7f Gracidea \\u00a7a+\\u00a7dx\\u00a72*";
          network-compression-threshold = 128;
          online-mode = true;
          op-permission-level = 4;
          player-idle-timeout = 0;
          prevent-proxy-connections = false;
          previews-chat = false;
          pvp = true;
          "query.port" = 25569;
          rate-limit = 0;
          "rcon.password" = "";
          "rcon.port" = 25579;
          require-resource-pack = false;
          resource-pack = "";
          resource-pack-prompt = "";
          resource-pack-sha1 = "";
          server-ip = "";
          simulation-distance = 10;
          snooper-enabled = false;
          spawn-animals = true;
          spawn-monsters = true;
          spawn-npcs = true;
          spawn-protection = 0;
          sync-chunk-writes = true;
          text-filtering-config = "";
          use-native-transport = true;
          view-distance = 12;
          white-list = true;
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
