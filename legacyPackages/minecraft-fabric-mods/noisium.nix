{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "noisium";
  version = "2.3.0+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/4sGQgiu2/noisium-fabric-2.3.0%2Bmc1.21-1.21.1.jar";
    hash = "sha256-wywWOGHpNrd4aZXr4SCet6TG57tJPnzHV0fdrDNAz4U=";
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
