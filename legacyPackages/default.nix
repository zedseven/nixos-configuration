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
        "hibp-offline-check"
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
        "almanac"
        "appleskin"
        "axes-are-weapons"
        "c2me"
        "carpet"
        "carpet-extra"
        "carpet-fixes"
        "cloth-config"
        "clumps"
        "convenient-mobgriefing"
        "explorify"
        "fabric-api"
        "fabrication"
        "ferrite-core"
        "geophilic"
        "hearths"
        "immersive-portals"
        "krypton"
        "let-me-despawn"
        "lithium"
        "memory-leak-fix"
        "mixin-trace"
        "modernfix"
        "noisium"
        "owo-lib"
        "scalablelux"
        "servux"
        "stitched-snow"
      ];
    };
  };
in
  builtins.listToAttrs (map legacyPackages hostSystems)
