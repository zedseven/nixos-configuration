{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.custom.desktop.printing;
in {
  options.custom.desktop.printing = with lib; {
    enable = mkEnableOption "printing functionality";
    drivers = mkOption {
      type = types.listOf (
        types.enum [
          "hp"
        ]
      );
      description = "The driver types to install.";
      default = [];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services = {
        printing.enable = true;

        # For autodiscovery of network printers
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        resolved.enable = lib.mkForce false; # Conflicts with `avahi` according to https://wiki.archlinux.org/title/Avahi#Hostname_resolution
      };
    })
    (lib.mkIf (builtins.elem "hp" cfg.drivers) {
      services.printing.drivers = [pkgs.hplip];
    })
  ];
}
