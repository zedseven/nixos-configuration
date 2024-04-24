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
      # Re-export packages from the `private` flake
      // {
        inherit (inputs.private.packages.${system}) dank-mono pragmatapro;
      };
  };
in
  builtins.listToAttrs (map packages hostSystems)
