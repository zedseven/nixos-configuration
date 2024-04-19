{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
  zip,
  jre_headless,
}: let
  lock = import ./lock.nix;
  libraries = lib.forEach lock.libraries fetchurl;
in
  stdenvNoCC.mkDerivation {
    inherit libraries;

    name = "fabric-server-launch.jar";

    nativeBuildInputs = [
      unzip
      zip
      jre_headless
    ];

    buildPhase = ''
      for i in $libraries; do
        unzip -o $i
      done

      cat > META-INF/MANIFEST.MF << EOF
      Manifest-Version: 1.0
      Main-Class: net.fabricmc.loader.impl.launch.server.FabricServerLauncher
      Name: org/objectweb/asm/
      Implementation-Version: 9.2
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
