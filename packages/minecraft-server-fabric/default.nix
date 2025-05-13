# Everything here comes from https://github.com/FabricMC/fabric-installer/issues/50#issuecomment-1013444858
# with additional modifications by me.
{
  lib,
  callPackage,
  writeText,
  stdenvNoCC,
  runtimeShell,
  jdk23_headless,
  minecraft-server-vanilla,
}: let
  lock = import ./lock.nix;
  loader = callPackage ./generate-loader.nix {};

  # This uses the same vanilla server version as in the lockfile, and uses the same JRE version for the vanilla and Fabric JARs
  #  escapeVersion = builtins.replaceStrings ["."] ["-"];
  #  vanillaMinorVersion = lib.concatStringsSep "." (
  #    lib.lists.take 2 (lib.strings.splitString "." lock.minecraftVersion)
  #  );
  #  escapedVanillaMinorVersion = escapeVersion vanillaMinorVersion;
  vanillaServer = minecraft-server-vanilla.override {
    jre_headless = jdk23_headless;
  };

  log4jConfiguration = let
    fileName = "log4j.xml";
    storePath = lib.fileset.toSource {
      root = ./.;
      fileset = ./. + "/${fileName}";
    };
  in "${storePath}/${fileName}";

  # https://github.com/FabricMC/fabric-loader/blob/63840270caa7f7e0a660354577afe19d133bff77/src/main/java/net/fabricmc/loader/impl/launch/server/FabricServerLauncher.java#L52
  launcherProperties = writeText "fabric-server-launcher.properties" ''
    serverJar=${vanillaServer}/lib/minecraft/server.jar
    launch.mainClass=${lock.mainClass}
  '';

  mainProgram = "minecraft-server";
in
  # Ensure the vanilla server version matches the Fabric server version
  assert minecraft-server-vanilla.version == lock.minecraftVersion;
    stdenvNoCC.mkDerivation {
      pname = "minecraft-server-fabric";
      version = "${lock.minecraftVersion}-${lock.loaderVersion}";

      installPhase = ''
        mkdir -p $out/bin


        cat > $out/bin/${mainProgram} << EOF
        #!${runtimeShell}

        # Create a link to the Fabric loader properties file in the working directory
        ln -sf ${launcherProperties} fabric-server-launcher.properties

        # Execute
        exec ${jdk23_headless}/bin/java -Dlog4j.configurationFile=${log4jConfiguration} \$@ -jar ${loader} nogui
        EOF


        chmod +x $out/bin/${mainProgram}
      '';

      dontUnpack = true;

      meta = {
        inherit mainProgram;
        homepage = "https://fabricmc.net/";
        description = "The server version of a modular, lightweight mod loader for Minecraft";
        license = lib.licenses.unfreeRedistributable;
        maintainers = with lib.maintainers; [zedseven];
        platforms = lib.platforms.all;
        sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      };
    }
