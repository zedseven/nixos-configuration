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
    value = let
      alejandra = callPackage ./alejandra {};
    in {
      inherit alejandra;
      lavalink = callPackage ./lavalink.nix {};
      lavalinkPlugins = recurseIntoAttrs (callPackage ./lavalinkPlugins {});
      purefmt = callPackage ./purefmt.nix {inherit alejandra;};
      steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
    };
  };
in
  builtins.listToAttrs (map packages hostSystems)
