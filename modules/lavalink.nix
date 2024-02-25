{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}: let
  cfg = config.custom.lavalink;
  defaultIdentity = "lavalink";
in {
  imports = [
    ./symlinks.nix
  ];

  options.custom.lavalink = with lib; {
    enable = mkEnableOption "the service for running Lavalink";
    user = mkOption {
      description = "The user to run Lavalink under.";
      type = types.str;
      default = defaultIdentity;
    };
    group = mkOption {
      description = "The group to run Lavalink under.";
      type = types.str;
      default = defaultIdentity;
    };
    package = mkOption {
      description = "The Lavalink package to use.";
      type = types.package;
      default = inputs.self.packages.${system}.lavalink;
      defaultText = lib.literalExpression "inputs.self.packages.\${system}.lavalink";
    };
    address = mkOption {
      description = "The address to bind to.";
      type = types.str;
      default = "0.0.0.0";
    };
    port = mkOption {
      description = "The port to bind to.";
      type = types.port;
      default = 2333;
    };
    password = mkOption {
      description = ''
        The password for clients to connect to the server with.
        Lavalink does not currently provide a way to read the password from a file at runtime.
      '';
      type = types.str;
    };
    logDirectory = mkOption {
      description = "The directory to write logs to.";
      type = types.path;
      default = "/var/log/lavalink";
    };
    plugins = mkOption {
      description = "The set of plugins to run with.";
      type = types.listOf types.package;
      default = [];
    };
    extraConfig = mkOption {
      description = "The extra configuration to add to `application.yml`.";
      type = types.anything;
      default = {};
    };
  };

  config =
    lib.mkIf cfg.enable
    (let
      # Based upon:
      # - https://lavalink.dev/configuration/#example-applicationyml
      # - https://github.com/lavalink-devs/Lavalink/blob/ae3deb1ad61ea31f040ddaa4a283a38c298f326f/LavalinkServer/application.yml.example
      configurationContents = lib.generators.toYAML {} ({
          server = {
            inherit (cfg) address port;
          };
          lavalink.server = {
            inherit (cfg) password;
          };
          logging.file.path = cfg.logDirectory;
        }
        // cfg.extraConfig);
      configurationFile = let
        fileName = "application.yml";
      in
        pkgs.writeTextFile {
          name = fileName;
          text = configurationContents;
          destination = "/${fileName}";
        };
      completeConfiguration = pkgs.symlinkJoin {
        name = "lavalink-service-configuration";
        paths = [configurationFile] ++ cfg.plugins;
      };
    in {
      systemd.tmpfiles.rules = [
        "d ${cfg.logDirectory} 664 ${cfg.user} ${cfg.group}"
      ];

      # Based upon https://lavalink.dev/configuration/systemd.html
      systemd.services."lavalink" = {
        enable = true;
        description = "Lavalink";
        after = ["syslog.target" "network.target"];
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/lavalink";
          ExecStartPost = "${pkgs.coreutils}/bin/sleep 15"; # Allows the service to properly start up before any dependent services start
          WorkingDirectory = "${completeConfiguration}";
          Restart = "on-failure";
          RestartSec = "5s";
          User = cfg.user;
          Group = cfg.group;
        };
        wantedBy = ["multi-user.target"];
      };

      users.users = lib.attrsets.optionalAttrs (cfg.user == defaultIdentity) {
        ${defaultIdentity} = {
          group = cfg.group;
          #uid = config.ids.uids.${defaultIdentity};
          isSystemUser = true;
        };
      };

      users.groups = lib.attrsets.optionalAttrs (cfg.group == defaultIdentity) {
        ${defaultIdentity} = {
          #gid = config.ids.gids.${defaultIdentity};
        };
      };
    });
}
