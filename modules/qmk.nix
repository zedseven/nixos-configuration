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
    enable = mkEnableOption "QMK keyboard firmware setup";
    installPackage = mkEnableOption "automatic installation of the QMK firmware tools";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      hardware.keyboard.qmk.enable = true;
    }
    (lib.mkIf cfg.installPackage {
      users.users.${userInfo.username}.packages = with pkgs; [qmk];
    })
  ]);
}
