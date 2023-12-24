# Wipe the root directory on boot
# NixOS will rebuild it every time, giving the system a "new computer feel" on every boot
# This also tests the system's ability to build from scratch
# https://grahamc.com/blog/erase-your-darlings/
{
  config,
  lib,
  ...
}: let
  cfg = config.environment.darlings;
in {
  imports = [
    ./symlinks.nix
  ];

  options.environment.darlings = with lib; {
    enable = mkEnableOption "erase-your-darlings";
    wipeCommand = mkOption {
      description = "The command to run to wipe the root partition. Run on boot, after the devices are set up.";
      type = types.str;
      default = "zfs rollback -r rpool/local/root@blank";
    };
    persist = {
      mirrorRoot = mkOption {
        description = "The root directory to mirror the paths under.";
        type = types.path;
        default = "/persist";
      };
      paths = mkOption {
        description = "The paths to persist.";
        type = types.listOf types.path;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkAfter cfg.wipeCommand;

    environment.symlinks = builtins.listToAttrs (map (path: {
        name = path;
        value = {
          source = cfg.persist.mirrorRoot + path;
        };
      })
      cfg.persist.paths);
  };
}
