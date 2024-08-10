{
  config,
  lib,
  ...
}: let
  cfg = config.custom.desktop;
in {
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver = {
    videoDrivers = ["nvidia"];

    # Set `metamodes` to potentially enable Adaptive Sync
    screenSection = let
      gSyncOn = "{AllowGSYNCCompatible=On}";

      metamodesStr = lib.concatStringsSep ", " (
        lib.mapAttrsToList (
          output: config:
            "${output}: ${(builtins.toString config.resolutionX)}x${(builtins.toString config.resolutionY)}_${(builtins.toString config.rate)} +${(builtins.toString config.positionX)}+${(builtins.toString config.positionY)}"
            + (lib.optionalString config.adaptiveSync " ${gSyncOn}")
        )
        cfg.displays.config
      );
    in ''
      Option "metamodes" "${metamodesStr}"
    '';
  };
}
