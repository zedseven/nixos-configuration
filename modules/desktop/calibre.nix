{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.calibre;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.calibre = with lib; {
    enable = mkEnableOption "Calibre";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${userInfo.username}.home.packages = with pkgs; [calibre];

    # https://www.mobileread.com/forums/showthread.php?t=350674
    services.udisks2.enable = true;
  };
}
