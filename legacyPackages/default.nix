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
      keepassPlugins = includePackages ./keepass-plugins [
        "app-id-linker"
        "keetheme"
        "patternpass"
        "yet-another-favicon-downloader"
      ];
      lavalinkPlugins = includePackages ./lavalink-plugins [
        "dunctebot"
        "lavasrc"
        "youtube-source"
      ];
      minecraftFabricMods = includePackages ./minecraft-fabric-mods [
        "aether"
        "appleskin"
        "c2me"
        "carpet"
        "carpet-extra"
        "carpet-fixes"
        "clumps"
        "fabric-api"
        "ferrite-core"
        "immersive-portals"
        "krypton"
        "let-me-despawn"
        "lithium"
        "memory-leak-fix"
        "mixin-trace"
        "noisium"
        "owo-lib"
        "stitched-snow"
      ];
    };
  };
in
  builtins.listToAttrs (map legacyPackages hostSystems)
