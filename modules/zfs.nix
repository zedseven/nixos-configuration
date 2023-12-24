{
  config,
  lib,
  ...
}: let
  cfg = config.custom.zfs;
in {
  options.custom.zfs = with lib; {
    enable = mkEnableOption "ZFS customisations";
  };

  config = lib.mkIf cfg.enable {
    services.zfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };
}
