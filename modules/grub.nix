{
  config,
  lib,
  ...
}: let
  cfg = config.custom.grub;
in {
  options.custom.grub = with lib; {
    enable = mkEnableOption "GRUB boot loader settings";
    efiSupport = mkEnableOption "EFI support";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot.loader = {
          grub = {
            enable = true;
            device = lib.mkDefault "nodev";
          };
        };
      }
      (lib.mkIf cfg.efiSupport {
        boot.loader = {
          efi.canTouchEfiVariables = true;
          grub.efiSupport = true;
        };
      })
    ]
  );
}
