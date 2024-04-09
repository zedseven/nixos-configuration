{
  inputs,
  hostSystems,
  ...
}: let
  packages = system: let
    inherit (inputs.nixpkgs.legacyPackages.${system}) callPackage;
  in {
    name = system;
    value = let
      alejandra = callPackage ./alejandra {};
    in {
      inherit alejandra;
      lavalink = callPackage ./lavalink.nix {};
      lavalinkPluginDunctebot = callPackage ./lavalinkPlugins/dunctebot.nix {};
      lavalinkPluginLavasrc = callPackage ./lavalinkPlugins/lavasrc.nix {};
      purefmt = callPackage ./purefmt.nix {inherit alejandra;};
      steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
    };
  };
in
  builtins.listToAttrs (map packages hostSystems)
