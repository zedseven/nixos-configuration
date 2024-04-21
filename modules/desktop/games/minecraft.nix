{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.games.minecraft;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../symlinks.nix
  ];

  options.custom.desktop.games.minecraft = with lib; {
    enable = mkEnableOption "Minecraft";
    server = {
      enable = mkEnableOption "server installation";
      package = mkOption {
        description = "The package to use for the Minecraft server.";
        type = types.package;
        default = pkgs.minecraft-server;
        defaultText = lib.literalExpression "pkgs.minecraft-server";
      };
      port = mkOption {
        description = "The port to bind to.";
        type = types.port;
        default = 25565;
      };
      dataDir = mkOption {
        description = "The directory for the server state.";
        type = types.path;
        default = "/var/lib/minecraft";
      };
      serverProperties = mkOption {
        description = "The server properties. The port will be added automatically.";
        type = types.attrsOf (
          types.oneOf [
            types.bool
            types.int
            types.str
          ]
        );
      };
      whitelistFile = mkOption {
        description = "The path to the file that contains the user whitelist.";
        type = types.nullOr types.path;
        default = null;
      };
      operatorsFile = mkOption {
        description = "The path to the file that contains the operator list.";
        type = types.nullOr types.path;
        default = null;
      };
      iconFile = mkOption {
        description = "The path to the icon PNG file to display. It must be 64×64px in size.";
        type = types.nullOr types.path;
        default = null;
      };
      memoryAllocatedGigabytes = mkOption {
        description = "The amount of RAM to allocate for the server.";
        type = types.int;
        default = 4;
      };
      aikarsFlags = mkOption {
        description = "Whether to include Aikar's flags in the JVM options for increased garbage collector performance.";
        type = types.bool;
        default = false;
      };
      extraJvmOpts = mkOption {
        description = "Extra JVM options for the Minecraft server.";
        type = types.separatedString " ";
        default = "";
      };
      mods = mkOption {
        description = "The mods to load. All mod packages are expected to have a structure like: `$out/mods/<MOD>.jar`";
        type = types.listOf types.package;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # User installation
      (lib.mkIf (!cfg.server.enable) {
        home-manager.users.${userInfo.username}.home.packages = [pkgs.prismlauncher];
      })

      # Server installation
      (lib.mkIf cfg.server.enable {
        services.minecraft-server = {
          inherit (cfg.server) dataDir package;
          enable = true;
          eula = true;
          jvmOpts = let
            memoryAllocatedGigabytes = builtins.toString cfg.server.memoryAllocatedGigabytes;
          in
            "-Xms${memoryAllocatedGigabytes}G -Xmx${memoryAllocatedGigabytes}G ${cfg.server.extraJvmOpts}"
            + (
              # https://docs.papermc.io/paper/aikars-flags
              # https://flags.sh/
              lib.optionalString cfg.server.aikarsFlags
              " -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200
                -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch
                -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M
                -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4
                -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90
                -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem
                -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs
                -Daikars.new.flags=true"
            );
        };

        # The whitelist and server properties are generated & symlinked manually instead of using the provided
        # functionality from the module.
        # This is so that the whitelist can be stored within `agenix`.
        custom.symlinks = let
          # https://minecraft.wiki/w/Server.properties
          defaultServerProperties = {
            allow-flight = false;
            allow-nether = true;
            broadcast-console-to-ops = true;
            broadcast-rcon-to-ops = true;
            debug = false;
            difficulty = "easy";
            enable-command-block = false;
            enable-jmx-monitoring = false;
            enable-query = false;
            enable-rcon = false;
            enable-status = true;
            enforce-secure-profile = true;
            enforce-whitelist = cfg.server.whitelistFile != null;
            entity-broadcast-range-percentage = 100;
            force-gamemode = false;
            function-permission-level = 2;
            gamemode = "survival";
            generate-structures = true;
            generator-settings = "{}";
            hardcore = false;
            hide-online-players = false;
            initial-disabled-packs = "";
            initial-enabled-packs = "vanilla";
            level-name = "world";
            level-seed = "";
            level-type = "minecraft:normal";
            log-ips = true;
            max-chained-neighbor-updates = 1000000;
            max-players = 20;
            max-tick-time = 60000;
            max-world-size = 29999984;
            motd = "A Minecraft Server";
            network-compression-threshold = 256;
            online-mode = true;
            op-permission-level = 4;
            player-idle-timeout = 0;
            prevent-proxy-connections = false;
            previews-chat = false;
            pvp = true;
            "query.port" = 25565;
            rate-limit = 0;
            "rcon.password" = "";
            "rcon.port" = 25575;
            region-file-compression = "deflate";
            require-resource-pack = false;
            resource-pack = "";
            resource-pack-id = "";
            resource-pack-prompt = "";
            resource-pack-sha1 = "";
            server-ip = "";
            server-port = 25565;
            simulation-distance = 10;
            snooper-enabled = false;
            spawn-animals = true;
            spawn-monsters = true;
            spawn-npcs = true;
            spawn-protection = 16;
            sync-chunk-writes = true;
            text-filtering-config = "";
            use-native-transport = true;
            view-distance = 10;
            white-list = cfg.server.whitelistFile != null;
          };

          valueToString = v:
            if builtins.isBool v
            then lib.boolToString v
            else builtins.toString v;
          serverPropertiesComplete =
            defaultServerProperties // cfg.server.serverProperties // {server-port = cfg.server.port;};
          serverPropertiesFile = pkgs.writeText "server.properties" (
            ''
              # This file is automatically @generated by NixOS.
            ''
            + lib.concatStringsSep "\n" (
              lib.mapAttrsToList (n: v: "${n}=${valueToString v}") serverPropertiesComplete
            )
          );

          modsDirectory = pkgs.symlinkJoin {
            name = "minecraft-server-mods";
            paths = cfg.server.mods;
          };
        in
          lib.mkMerge [
            {
              "${cfg.server.dataDir}/server.properties".source = serverPropertiesFile;
              "${cfg.server.dataDir}/mods".source = "${modsDirectory}/mods";
            }
            (lib.mkIf (cfg.server.whitelistFile != null) {
              "${cfg.server.dataDir}/whitelist.json".source = cfg.server.whitelistFile;
            })
            (lib.mkIf (cfg.server.operatorsFile != null) {
              "${cfg.server.dataDir}/ops.json".source = cfg.server.operatorsFile;
            })
            (lib.mkIf (cfg.server.iconFile != null) {
              "${cfg.server.dataDir}/server-icon.png".source = cfg.server.iconFile;
            })
          ];

        # Open the firewall for the configured port
        networking.firewall.allowedTCPPorts = [cfg.server.port];
      })
    ]
  );
}
