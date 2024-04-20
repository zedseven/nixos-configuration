{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "noisium";
  version = "2.0.2+1.20.2";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/ZgEmwDsG/noisium-fabric-2.0.2+mc1.20.2-1.20.4.jar";
    hash = "sha256-jgHufA17qz1ZrlEi8isr7NWQX+kH0ZRQcjM3x1volF8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/noisium";
    description = "Optimises worldgen performance for a better gameplay experience";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
