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

  # TODO: Mods?
  options.custom.desktop.games.minecraft = with lib; {
    enable = mkEnableOption "Minecraft";
    server = {
      enable = mkEnableOption "server installation";
      package = mkOption {
        description = "The package to use for the Minecraft server.";
        type = types.package;
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
        type = types.path;
      };
      iconFile = mkOption {
        description = "The path to the icon PNG file to display.";
        type = types.nullOr types.path;
        default = null;
      };
      jvmOpts = mkOption {
        description = "JVM options for the Minecraft server.";
        type = types.separatedString " ";
        default = "-Xms512M -Xmx2048M";
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
          inherit (cfg.server) dataDir jvmOpts package;
          enable = true;
          eula = true;
        };

        # The whitelist and server properties are generated & symlinked manually instead of using the provided
        # functionality from the module.
        # This is so that the whitelist can be stored within `agenix`.
        custom.symlinks = let
          valueToString = v:
            if builtins.isBool v
            then lib.boolToString v
            else lib.toString v;
          serverPropertiesComplete =
            cfg.server.serverProperties
            // {
              server-port = cfg.server.port;
            };
          serverPropertiesFile = pkgs.writeText "server.properties" (
            ''
              # This file is automatically @generated by NixOS.
            ''
            + lib.concatStringsSep "\n" (
              lib.mapAttrsToList (n: v: "${n}=${valueToString v}") serverPropertiesComplete
            )
          );
        in
          lib.mkMerge [
            {
              "${cfg.dataDir}/server.properties".source = serverPropertiesFile;
              "${cfg.dataDir}/whitelist.json".source = cfg.server.whitelistFile;
            }
            (lib.mkIf (cfg.server.iconFile != null) {
              "${cfg.dataDir}/server-icon.png".source = cfg.server.iconFile;
            })
          ];

        # Open the firewall for the configured port
        networking.firewall.allowedTCPPorts = [cfg.server.port];
      })
    ]
  );
}
