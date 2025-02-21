{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.stenography;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.stenography = with lib; {
    enable = mkEnableOption "stenography customisations";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${userInfo.username}.home.packages = with pkgs; [plover.dev];

    # Allow access to serial interfaces
    users.users.${userInfo.username}.extraGroups = ["dialout"];

    # Add `plover` as a high-priority program
    custom.desktop.suckless.dwm.highPriorityPrograms = ["plover"];
  };
}
