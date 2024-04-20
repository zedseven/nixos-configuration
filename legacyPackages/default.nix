{
  inputs,
  hostSystems,
  ...
}: let
  legacyPackages = system: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    inherit (pkgs) lib callPackage;

    includePackage = directory: package: {
      name = package;
      value = callPackage (directory + "/${package}.nix") {};
    };
    includePackages = directory: packages:
      lib.makeScope pkgs.newScope (_: builtins.listToAttrs (map (includePackage directory) packages));
  in {
    name = system;
    value = {
      lavalinkPlugins = includePackages ./lavalink-plugins [
        "dunctebot"
        "lavasrc"
      ];
    };
  };
in
  builtins.listToAttrs (map legacyPackages hostSystems)
