# Third-party Linux software for the EMS NDS Adapter+: http://www.hkems.com/product/nintendo/0907.htm
{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  system,
  ...
}: let
  cfg = config.custom.desktop.games.ndsplus;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.games.ndsplus.enable = lib.mkEnableOption "EMS NDS Adapter+ support";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userInfo.username}.home.packages = [inputs.self.packages.${system}.ndsplus];

    # https://github.com/Thulinma/ndsplus?tab=readme-ov-file#preparing-your-system
    services.udev.packages = let
      udevRule = pkgs.writeTextFile {
        name = "ndsplus.rules";
        destination = "/etc/udev/rules.d/ndsplus.rules";
        text = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="4670", ATTRS{idProduct}=="9394", GROUP="users", MODE="0666", SYMLINK="ndsplus"
        '';
      };
    in [udevRule];
  };
}
