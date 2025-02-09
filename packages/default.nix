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
        autopatchelf = callPackage ./autopatchelf.nix {};
        lavalink = callPackage ./lavalink.nix {};
        minecraft-server-fabric = callPackage ./minecraft-server-fabric {};
        ndsplus = callPackage ./ndsplus.nix {};
        neovim = callPackage ./neovim {inherit inputs purefmt;};
        purefmt = callPackage ./purefmt.nix {inherit alejandra;};
        qemu-guest = callPackage ./qemu-guest.nix {};
        sharpii = callPackage ./sharpii.nix {}; # Technically, it will only work on x86_64 at the moment
        st = callPackage ./suckless/st {};
        steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
        tealdeer = callPackage ./tealdeer.nix {};
        win2xcur = callPackage ./win2xcur {};
        wireguard-vanity-address = callPackage ./wireguard-vanity-address.nix {};
      }
      # Re-export packages from other flakes
      // {
        inherit (inputs.private.packages.${system}) dank-mono pragmatapro;

        breeze = inputs.breeze.packages.${system}.default;
        radium = inputs.radium.packages.${system}.default;
      };
  };
in
  builtins.listToAttrs (map packages hostSystems)
