{
  config,
  lib,
  ...
}: let
  cfg = config.custom.desktop.games;
in {
  options.custom.desktop.games = with lib; {
    enable = mkEnableOption "game customisations";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
