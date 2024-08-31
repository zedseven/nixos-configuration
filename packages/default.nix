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
        ndsplus = callPackage ./ndsplus.nix {};
        purefmt = callPackage ./purefmt.nix {inherit alejandra;};
        qemu-guest = callPackage ./qemu-guest.nix {};
        steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
        tealdeer = callPackage ./tealdeer.nix {};
        win2xcur = callPackage ./win2xcur {};
        wireguard-vanity-address = callPackage ./wireguard-vanity-address.nix {};
      }
      # Re-export packages from other flakes
      // {
        inherit (inputs.private.packages.${system}) dank-mono pragmatapro;
        breeze = inputs.breeze.packages.${system}.default;
      };
  };
in
  builtins.listToAttrs (map packages hostSystems)
