{
  config,
  lib,
  ...
} @ inputs: let
  cfg = config.custom.desktop;
in {
  options.custom.desktop = with lib; {
    displayDriver = mkOption {
      description = "The display driver to use.";
      type = types.enum ["nvidia"];
    };
  };

  config =
    lib.mkIf (cfg.displayDriver
      == "nvidia")
    ((import
      ./nvidia.nix)
    inputs);
}
