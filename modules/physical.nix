{
  config,
  lib,
  ...
}: let
  cfg = config.custom.physical;
in {
  options.custom.physical = with lib; {
    enable = mkEnableOption "physical device customisations";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
  };
}
