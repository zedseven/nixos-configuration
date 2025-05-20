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
    inherit (pkgs) lib callPackage;
  in {
    name = system;
    value =
      rec {
        alejandra = callPackage ./alejandra {};
        autopatchelf = callPackage ./autopatchelf.nix {};
        dmenu = callPackage ./suckless/dmenu {};
        dwm = callPackage ./suckless/dwm {};
        lavalink = callPackage ./lavalink.nix {};
        minecraft-server-fabric = callPackage ./minecraft-server-fabric {
          inherit minecraft-server-vanilla;
        };
        minecraft-server-vanilla = callPackage ./minecraft-server-vanilla.nix {};
        ndsplus = callPackage ./ndsplus.nix {};
        neovim = callPackage ./neovim {inherit inputs purefmt;};
        plover = callPackage ./plover.nix {};
        purefmt = callPackage ./purefmt.nix {inherit alejandra;};
        pyroveil = callPackage ./pyroveil.nix {};
        qemu-guest = callPackage ./qemu-guest.nix {};
        slock = callPackage ./suckless/slock {};
        slstatus = callPackage ./suckless/slstatus {};
        st = callPackage ./suckless/st {};
        steam-no-whats-new = callPackage ./steam-no-whats-new.nix {};
        steno-drill = callPackage ./steno-drill {};
        win2xcur = callPackage ./win2xcur {};
        wireguard-vanity-address = callPackage ./wireguard-vanity-address.nix {};
      }
      // lib.attrsets.optionalAttrs (system == "x86_64-linux") {
        sharpii = callPackage ./sharpii.nix {};
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
