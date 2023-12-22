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
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = let
      username = "zacc";
    in
      builtins.listToAttrs (map (host: {
          name = host.hostname;
          value = nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs =
              {
                inherit username;
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
