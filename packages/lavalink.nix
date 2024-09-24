{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  jre_headless,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lavalink";
  version = "4.0.7";

  src = fetchurl {
    url = "https://github.com/lavalink-devs/Lavalink/releases/download/${finalAttrs.version}/Lavalink.jar";
    hash = "sha256-HX9gxAM0hRaujulgjK8+8CvOjZSMCeuNAst59MPn1ZM=";
  };

  nativeBuildInputs = [makeWrapper];

  buildCommand = ''
    install -Dm644 $src $out/lib/Lavalink.jar

    mkdir -p $out/bin
    makeWrapper ${jre_headless}/bin/java $out/bin/lavalink \
      --add-flags "-jar $out/lib/Lavalink.jar"
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://lavalink.dev/";
    description = "Standalone audio sending node based on Lavaplayer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "lavalink";
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
