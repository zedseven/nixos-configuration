{
  inputs,
  hostSystems,
  ...
}: let
  packages = system: let
    inherit (inputs.nixpkgs.legacyPackages.${system}) callPackage;
    inherit (inputs.nixpkgs.lib.attrsets) recurseIntoAttrs;
  in {
    name = system;
    value = {
      lavalink = callPackage ./lavalink.nix {};
      lavalinkPlugins = recurseIntoAttrs (callPackage ./lavalinkPlugins {});
      steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
    };
  };
in
  builtins.listToAttrs (map packages hostSystems)
