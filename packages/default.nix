{nixpkgs, ...}: let
  packages = system: let
    inherit (nixpkgs.legacyPackages.${system}) callPackage;
  in {
    name = system;
    value = {
      steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
    };
  };
in
  builtins.listToAttrs (map packages ["x86_64-linux"])
