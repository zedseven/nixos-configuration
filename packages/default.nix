{
  inputs,
  hostSystems,
  ...
}: let
  packages = system: let
    inherit (inputs.nixpkgs.legacyPackages.${system}) callPackage;
  in {
    name = system;
    value = {
      lavalink = callPackage ./lavalink.nix {};
      steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
    };
  };
in
  builtins.listToAttrs (map packages hostSystems)
