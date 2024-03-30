{
  config,
  lib,
  ...
}: let
  cfg = config.custom.grub;
in {
  options.custom.grub = with lib; {
    enable = mkEnableOption "GRUB boot loader settings";
    efi = {
      enable = mkEnableOption "EFI support";
      installAsRemovable = mkEnableOption "installation as removable media, which can help with problematic systems";
    };
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
      (lib.mkIf cfg.efi.enable (
        lib.mkMerge [
          {boot.loader.grub.efiSupport = true;}
          (lib.mkIf cfg.efi.installAsRemovable {boot.loader.grub.efiInstallAsRemovable = true;})
          (lib.mkIf (!cfg.efi.installAsRemovable) {boot.loader.efi.canTouchEfiVariables = true;})
        ]
      ))
    ]
  );
}
