{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.android;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.android = with lib; {
    enable = mkEnableOption "Android development tools";
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.${userInfo.username}.extraGroups = [
      "adbusers"
      "kvm" # For virtualisation support
    ];

    home-manager.users.${userInfo.username}.home.packages = with pkgs; [android-studio];
  };
}
