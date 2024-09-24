{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lavasrc";
  version = "4.2.0";

  src = fetchurl {
    url = "https://github.com/topi314/LavaSrc/releases/download/${finalAttrs.version}/lavasrc-plugin-${finalAttrs.version}.jar";
    hash = "sha256-NoyRphbDPWLnu7LO90NMqECUnm3/h/kiQHnQNZiMofU=";
  };

  buildCommand = ''
    install -Dm644 $src $out/plugins/lavasrc-plugin.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://github.com/topi314/LavaSrc";
    description = "A collection of additional Lavaplayer/Lavalink Sources";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
