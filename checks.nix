{
  inputs,
  hostSystems,
  ...
}: let
  checks = system: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};

    revision = inputs.self.rev or inputs.self.dirtyRev;
    checkPrefix = "check";
    runSuffix = "run-${revision}";
  in {
    name = system;
    value = {
      formatting = pkgs.runCommand "${checkPrefix}-formatting-${runSuffix}" {} ''
        set -o errexit

        ${inputs.self.packages.${system}.alejandra}/bin/alejandra --check ${inputs.self} | tee $out
      '';

      lints = pkgs.runCommand "${checkPrefix}-lints-${runSuffix}" {} ''
        set -o errexit

        ${pkgs.statix}/bin/statix check ${inputs.self} | tee $out
        ${pkgs.deadnix}/bin/deadnix --hidden --fail ${inputs.self} | tee --append $out
      '';
    };
  };
in
  builtins.listToAttrs (map checks hostSystems)
