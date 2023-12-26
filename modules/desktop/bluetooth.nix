{
  config,
  lib,
  ...
}: let
  cfg = config.custom.desktop.bluetooth;
in {
  options.custom.desktop.bluetooth = with lib; {
    enable = mkEnableOption "Bluetooth customisations";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
