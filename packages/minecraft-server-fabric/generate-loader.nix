{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
  zip,
  jre_headless,
}: let
  lock = import ./lock.nix;
  libraries = lib.forEach lock.libraries (
    library:
      fetchurl {
        inherit (library) url sha256;
        name = library.fileName;
      }
  );
  asmVersion = (lib.lists.findFirst (library: library.name == "asm") null lock.libraries).version;
  asmVersionMinor = lib.strings.concatStringsSep "." (
    lib.lists.take 2 (lib.strings.splitString "." asmVersion)
  );
in
  stdenvNoCC.mkDerivation {
    inherit asmVersionMinor libraries;

    name = "fabric-server-launch.jar";

    nativeBuildInputs = [
      unzip
      zip
      jre_headless
    ];

    # The `Implementation-Version` field is really important - it's used along with the actual Java version to determine the Java compatibility level:
    # https://github.com/SpongePowered/Mixin/blob/4053421aa10aaac6127d969028a29c94fe3054f6/src/main/java/org/spongepowered/asm/mixin/MixinEnvironment.java#L847
    buildPhase = ''
      for i in $libraries; do
        unzip -o $i
      done

      cat > META-INF/MANIFEST.MF << EOF
      Manifest-Version: 1.0
      Main-Class: net.fabricmc.loader.impl.launch.server.FabricServerLauncher
      Name: org/objectweb/asm/
      Implementation-Version: $asmVersionMinor
      EOF
    '';

    installPhase = ''
      jar cmvf META-INF/MANIFEST.MF "server.jar" .
      zip -d server.jar 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*.DSA'
      cp server.jar "$out"
    '';

    phases = [
      "buildPhase"
      "installPhase"
    ];
  }
