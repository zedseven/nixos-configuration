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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    programs-db = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = ""; # Not necessary on Linux
      };
    };
    private = {
      # Add the flake to the registry with: `nix registry add flake:private git+file:///path/to/local/repo`
      url = "flake:private";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        agenix.follows = "agenix";
      };
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
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
            specialArgs =
              {
                inherit userInfo;
                inherit (host) system hostname;
              }
              // inputs;
            modules = [./hosts];
          };
        }) [
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
  };
}
