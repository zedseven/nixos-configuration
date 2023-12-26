{
  config,
  pkgs,
  lib,
  hostname,
  userInfo,
  ...
}: let
  cfg = config.custom.backups;
in {
  options.custom.backups = with lib; {
    enable = mkEnableOption "backups";
    repository = mkOption {
      description = mdDoc ''
        The repository to backup to.

        If using `rclone`, the `rclone:` prefix is added automatically.
      '';
      type = types.str;
    };
    backupPaths = mkOption {
      description = mdDoc "The paths to backup.";
      type = types.listOf types.str;
    };
    passwordFile = mkOption {
      description = mdDoc "The path to file that contains the Restic repository password.";
      type = types.path;
    };
    extraExcludeEntries = mkOption {
      description = mdDoc "The extra exclude config, appended to the global one.";
      type = types.listOf types.str;
      default = [];
    };
    rclone = {
      enable = mkEnableOption "rclone";
      package = mkOption {
        description = mdDoc "The package to use for `rclone`.";
        type = types.package;
        default = pkgs.rclone;
        defaultText = lib.literalExpression "pkgs.rclone";
      };
      configPath = mkOption {
        description = mdDoc "An alternate path to the `rclone` config file. If not defined, `rclone` will look in its default location.";
        type = types.nullOr types.path;
        default = null;
      };
    };
    scheduled = {
      enable = mkOption {
        description = "Whether to set up scheduled backups.";
        type = types.bool;
        default = true;
      };
      onCalendar = mkOption {
        description = mdDoc ''
          The interval to run the scheduled backups at.
          This corresponds to the `OnCalendar` systemd timer option.

          See https://wiki.archlinux.org/title/Systemd/Timers for more information.
        '';
        type = types.str;
        default = "daily";
      };
      requiresNetwork = mkOption {
        description = "Whether the backup repository requires active networking to access.";
        type = types.bool;
        default = cfg.rclone.enable;
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    repository = (lib.optionalString cfg.rclone.enable "rclone:") + cfg.repository;
    excludeFile = pkgs.writeText "exclude.txt" ''
      ${builtins.readFile ./exclude.global.txt}
      ${lib.concatLines cfg.extraExcludeEntries}
    '';
    backupSpecs =
      lib.concatMapStrings
      (backupPath: let
        escapedFilename = lib.replaceStrings ["/" " "] ["-" "-"] (lib.removePrefix "/" backupPath);
      in "\"${backupPath};${escapedFilename}.txt\"\n")
      cfg.backupPaths;
    runBackup = pkgs.writeShellScriptBin "run-backup" ''
      # Constants
      TREES_DIR="$(mktemp -d)"
      RESTIC_EXCLUDE_FILE="${excludeFile}"
      RESTIC_HOSTNAME="${hostname}"

      # Environment Variables
      export RESTIC_REPOSITORY="${repository}"
      export RESTIC_COMPRESSION="max"
      export RESTIC_PASSWORD_FILE="${cfg.passwordFile}"
      ${
        lib.optionalString cfg.rclone.enable
        (lib.optionalString (cfg.rclone.configPath != null) "export RCLONE_CONFIG=\"${cfg.rclone.configPath}\"\n")
        + "PATH=\"${cfg.rclone.package}/bin\${PATH:+:\${PATH}}\"\n"
      }

      # Directories to Backup
      declare -a BACKUP_SPECS=(
        ${backupSpecs}
      )

      declare -a BACKUP_DIRS=()

      # Process each entry to build the arguments list and generate tree files
      for BACKUP_SPEC in "''${BACKUP_SPECS[@]}"; do
        # Split the entry on the `;` character
        SPLIT=(''${BACKUP_SPEC//;/ })
        BACKUP_DIR="''${SPLIT[0]}"
        TREE_FILE="''${SPLIT[1]}"

        # Generate the tree file to archive the list of all files and their locations
        ${pkgs.tree}/bin/tree --dirsfirst -F -a "$BACKUP_DIR" > "$TREES_DIR/$TREE_FILE"

        # Append the directory to the arguments list
        BACKUP_DIRS+=("$BACKUP_DIR")
      done

      # Backup the tree file directory
      BACKUP_DIRS+=("$TREES_DIR")

      # Backup the directories
      ${pkgs.restic}/bin/restic backup --exclude-caches --exclude-file="$RESTIC_EXCLUDE_FILE" --host="$RESTIC_HOSTNAME" "''${BACKUP_DIRS[@]}"

      # Delete the temporary tree file directory
      rm -rf "$TREES_DIR"
    '';
  in
    lib.mkMerge [
      {
        users.users.${userInfo.username} = {
          packages = [
            runBackup
          ];
        };
      }
      (lib.mkIf cfg.scheduled.enable {
        systemd = {
          services."run-backup" = lib.mkMerge [
            {
              enable = true;
              description = "run-backup";
              serviceConfig = {
                User = userInfo.username;
                ExecStart = "${runBackup}/bin/run-backup";
              };
            }
            (lib.mkIf cfg.scheduled.requiresNetwork {
              requires = ["network-online.target"];
            })
          ];

          timers."run-backup" = {
            timerConfig = {
              OnCalendar = cfg.scheduled.onCalendar;
              Persistent = true;
              Unit = "run-backup.service";
            };
            wantedBy = ["timers.target"];
          };
        };
      })
    ]);
}
