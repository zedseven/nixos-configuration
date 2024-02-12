{
  description = "The NixOS configurations for all of Zacchary Dempsey-Plante's systems.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    programs-db = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = ""; # Not necessary on Linux
        systems.follows = "systems";
      };
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add the flakes to the registry with: `nix registry add flake:<NAME> git+file:///path/to/local/repo`
    private = {
      url = "flake:private";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        agenix.follows = "agenix";
      };
    };
    website-ztdp = {
      url = "flake:website-ztdp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The below inputs aren't used directly, but they're included here so that the other dependencies all
    # use the same versions of them
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = {nixpkgs, ...} @ inputs: {
    packages = import ./packages inputs;

    nixosConfigurations = let
      userInfo = {
        username = "zacc";
        name = "Zacchary Dempsey-Plante";
        email = "zacc@ztdp.ca";
        gpgKeyId = "64FABC62F4572875";
      };
    in
      builtins.listToAttrs (map (host: {
          name = host.hostname;
          value = nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = {
              inherit inputs;
              inherit userInfo;
              inherit (host) system hostname;
            };
            modules = [./hosts];
          };
        }) [
          {
            hostname = "autori";
            system = "x86_64-linux";
          }
          {
            hostname = "diiamo";
            system = "x86_64-linux";
          }
          {
            hostname = "duradeus";
            system = "x86_64-linux";
          }
          {
            hostname = "wraith";
            system = "x86_64-linux";
          }
        ]);

    formatter = builtins.listToAttrs (map (system: {
      name = system;
      value = nixpkgs.legacyPackages.${system}.alejandra;
    }) ["x86_64-linux"]);
  };
}
