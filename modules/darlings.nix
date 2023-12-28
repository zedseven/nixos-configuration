# Wipe the root directory on boot
# NixOS will rebuild it every time, giving the system a "new computer feel" on every boot
# This also tests the system's ability to build from scratch
# https://grahamc.com/blog/erase-your-darlings/
{
  config,
  lib,
  ...
}: let
  cfg = config.custom.darlings;
in {
  imports = [
    ./symlinks.nix
  ];

  options.custom.darlings = with lib; {
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
      ageIdentityPaths = let
        defaultAgeIdentityDir = "/etc/ssh";
        defaultKeyFileName = "ssh_host_ed25519_key";
      in {
        enable = mkOption {
          description = "Whether to set `age.identityPaths`.";
          type = types.bool;
          default = lib.any (path: lib.hasPrefix defaultAgeIdentityDir path) cfg.persist.paths; # Enable automatically if the path list contains the default age identity path
        };
        identityPaths = mkOption {
          description = "The paths to the age identities to use.";
          type = types.listOf types.path;
          default = [
            (cfg.persist.mirrorRoot + defaultAgeIdentityDir + "/ssh_host_rsa_key")
            (cfg.persist.mirrorRoot + defaultAgeIdentityDir + "/ssh_host_ed25519_key")
          ];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      boot.initrd.postDeviceCommands = lib.mkAfter cfg.wipeCommand;

      custom.symlinks = builtins.listToAttrs (map (path: {
          name = path;
          value = {
            source = cfg.persist.mirrorRoot + path;
          };
        })
        cfg.persist.paths);
    }
    (lib.mkIf cfg.persist.ageIdentityPaths.enable {
      # Required because on boot, the root partition is wiped and the symlinks seem to be set up after `agenix` runs
      # This is merged with the default values that `agenix` provides
      age.identityPaths = lib.mkOptionDefault cfg.persist.ageIdentityPaths.identityPaths;
    })
  ]);
}
