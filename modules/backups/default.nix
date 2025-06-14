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
    extraExcludeEntriesAreCaseSensitive = mkOption {
      description = "Whether the extra exclude entries are case-sensitive.";
      type = types.bool;
      default = true;
    };
    setEnvironmentVariables = mkOption {
      description = mdDoc ''
        Whether to set the environment variables `RESTIC_PASSWORD_FILE` and (if `rclone` is enabled) `RCLONE_CONFIG` so
        that backups can be accessed from the command line with `restic`.
      '';
      type = types.bool;
      default = false;
    };
    maxRecursion = mkOption {
      description = "The maximum directory recursion allowed. A value of 0 implies no limit.";
      type = types.ints.unsigned;
      default = 0;
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
      serviceUser = mkOption {
        description = "The user to run the scheduled backups under.";
        type = types.str;
        default = "root";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      repository = (lib.optionalString cfg.rclone.enable "rclone:") + cfg.repository;
      excludeFileGlobal = ./exclude.global.txt;
      excludeFileExtra = pkgs.writeText "exclude.txt" (lib.concatLines cfg.extraExcludeEntries);
      extraExcludeCommandOption =
        if cfg.extraExcludeEntriesAreCaseSensitive
        then "exclude-file"
        else "iexclude-file";
      backupSpecs =
        lib.concatMapStrings (
          backupPath: let
            escapedFilename =
              lib.replaceStrings
              [
                "/"
                " "
              ]
              [
                "-"
                "-"
              ]
              (lib.removePrefix "/" backupPath);
          in ''
            "${backupPath};${escapedFilename}.txt"
          ''
        )
        cfg.backupPaths;

      repeatString = string: count: lib.concatStrings (map (_: string) (lib.lists.range 0 (count - 1)));
      recursionLimiter =
        lib.optionalString (cfg.maxRecursion > 0) "--exclude='"
        + (repeatString "/*" cfg.maxRecursion)
        + "'";

      # Used for executing automatic backups of the whole system
      runBackup = pkgs.writeShellScriptBin "run-backup" ''
        # Constants
        TREES_DIR="$(mktemp -d)"
        RESTIC_EXCLUDE_FILE_GLOBAL="${excludeFileGlobal}"
        RESTIC_EXCLUDE_FILE_EXTRA="${excludeFileExtra}"
        RESTIC_HOSTNAME="${hostname}"

        # Environment Variables
        export RESTIC_REPOSITORY="${repository}"
        export RESTIC_COMPRESSION="max"
        export RESTIC_PASSWORD_FILE="${cfg.passwordFile}"
        ${lib.optionalString cfg.rclone.enable (
          (lib.optionalString (cfg.rclone.configPath != null) ''
            export RCLONE_CONFIG="${cfg.rclone.configPath}"
          '')
          + ''
            PATH="${cfg.rclone.package}/bin''${PATH:+:''${PATH}}"
          ''
        )}

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
          ${pkgs.eza}/bin/eza --tree --all --group-directories-first --classify=always --colour=never "$BACKUP_DIR" > "$TREES_DIR/$TREE_FILE"

          # Append the directory to the arguments list
          BACKUP_DIRS+=("$BACKUP_DIR")
        done

        # Backup the tree file directory
        BACKUP_DIRS+=("$TREES_DIR")

        # Backup the directories
        ${pkgs.restic}/bin/restic backup --exclude-caches --exclude-file="$RESTIC_EXCLUDE_FILE_GLOBAL" --${extraExcludeCommandOption}="$RESTIC_EXCLUDE_FILE_EXTRA" ${recursionLimiter} --host="$RESTIC_HOSTNAME" "''${BACKUP_DIRS[@]}"

        # Delete the temporary tree file directory
        rm -rf "$TREES_DIR"
      '';

      # Used for executing one-off backups of external devices
      runBackupExternal = pkgs.writeShellScriptBin "run-backup-external" ''
        # Input arguments
        RESTIC_HOSTNAME="$1"
        BACKUP_DIR="$2"

        # Input validation
        if [[ -z "$RESTIC_HOSTNAME" ]]; then
          echo "USAGE: ''${BASH_SOURCE[0]} <RESTIC_HOSTNAME> <BACKUP_DIR>"
          >&2 echo "ERROR: Please provide the hostname to use for the external drive."
          exit 1
        fi
        if [[ -z "$BACKUP_DIR" ]]; then
          >&2 echo "ERROR: Please provide the backup path."
          exit 1
        fi

        # Constants
        TREES_DIR="$(mktemp -d)"
        RESTIC_EXCLUDE_FILE_GLOBAL="${excludeFileGlobal}"

        # Environment Variables
        export RESTIC_REPOSITORY="${repository}"
        export RESTIC_COMPRESSION="max"
        export RESTIC_PASSWORD_FILE="${cfg.passwordFile}"
        ${lib.optionalString cfg.rclone.enable (
          (lib.optionalString (cfg.rclone.configPath != null) ''
            export RCLONE_CONFIG="${cfg.rclone.configPath}"
          '')
          + ''
            PATH="${cfg.rclone.package}/bin''${PATH:+:''${PATH}}"
          ''
        )}

        # Generate the tree file name
        TREE_FILE="$RESTIC_HOSTNAME.txt"

        # Generate the tree file to archive the list of all files and their locations
        ${pkgs.eza}/bin/eza --tree --all --group-directories-first --classify=always --colour=never "$BACKUP_DIR" > "$TREES_DIR/$TREE_FILE"

        # Backup the directory
        ${pkgs.restic}/bin/restic backup --exclude-caches --exclude-file="$RESTIC_EXCLUDE_FILE_GLOBAL" ${recursionLimiter} --host="$RESTIC_HOSTNAME" "$BACKUP_DIR" "$TREES_DIR/$TREE_FILE"

        # Delete the temporary tree file directory
        rm -rf "$TREES_DIR"
      '';
    in
      lib.mkMerge [
        {
          users.users.${userInfo.username}.packages = [
            runBackup
            runBackupExternal
          ];

          # Add `runBackup` as a high-priority program
          # The script `runBackupExternal` isn't added because it must be run with arguments
          custom.desktop.suckless.dwm.highPriorityPrograms = [runBackup.name];
        }
        (lib.mkIf cfg.scheduled.enable {
          systemd = {
            services."run-backup" = lib.mkMerge [
              {
                enable = true;
                description = "run-backup";
                serviceConfig = {
                  User = cfg.scheduled.serviceUser;
                  ExecStart = "${runBackup}/bin/run-backup";
                };
              }
              (lib.mkIf cfg.scheduled.requiresNetwork {requires = ["network-online.target"];})
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
        (lib.mkIf cfg.setEnvironmentVariables {
          environment.sessionVariables = lib.mkMerge [
            {RESTIC_PASSWORD_FILE = cfg.passwordFile;}
            (lib.mkIf cfg.rclone.enable {RCLONE_CONFIG = cfg.rclone.configPath;})
          ];
        })
      ]
  );
}
