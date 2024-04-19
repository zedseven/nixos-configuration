{
  inputs,
  hostSystems,
  ...
}: let
  packages = system: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    inherit (pkgs) callPackage;
  in {
    name = system;
    value =
      rec {
        alejandra = callPackage ./alejandra {};
        lavalink = callPackage ./lavalink.nix {};
        minecraft-server-fabric = callPackage ./minecraft-server-fabric {};
        purefmt = callPackage ./purefmt.nix {inherit alejandra;};
        steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
        tealdeer = callPackage ./tealdeer.nix {};
      }
      // {
        lavalinkPlugin-dunctebot = callPackage ./lavalinkPlugins/dunctebot.nix {};
        lavalinkPlugin-lavasrc = callPackage ./lavalinkPlugins/lavasrc.nix {};
      };
  };
in
  builtins.listToAttrs (map packages hostSystems)
