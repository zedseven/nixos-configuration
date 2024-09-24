{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "youtube-source";
  version = "1.7.1";

  src = fetchurl {
    url = "https://github.com/lavalink-devs/youtube-source/releases/download/${finalAttrs.version}/youtube-plugin-${finalAttrs.version}.jar";
    hash = "sha256-DGAx+J3GiTga0lVrw4IGpj4JYMd7XgEcO1EMyXJ5/kk=";
  };

  buildCommand = ''
    install -Dm644 $src $out/plugins/youtube-plugin.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://github.com/lavalink-devs/youtube-source";
    description = "A rewritten YouTube source manager for Lavaplayer.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
