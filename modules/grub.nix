{
  config,
  lib,
  ...
}: let
  cfg = config.custom.grub;
in {
  options.custom.grub = with lib; {
    enable = mkEnableOption "GRUB boot loader settings";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = lib.mkDefault "nodev";
        efiSupport = true;
      };
    };
  };
}
