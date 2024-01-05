{
  config,
  pkgs,
  lib,
  userInfo,
  ...
}: let
  cfg = config.custom.qmk;
in {
  options.custom.qmk = with lib; {
    enable = mkEnableOption "QMK keyboard firmware tools";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;

    users.users.${userInfo.username}.packages = with pkgs; [qmk];
  };
}
