{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "carpet-fixes";
  version = "1.17.0";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/7Jaxgqip/versions/rJzXa8HU/carpet-fixes-1.20-1.17.0.jar";
    hash = "sha256-hL/oE5eKs2Eomsp6xMrONxxOAeR5nKAlYX7qhkkEvb8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/carpet-fixes";
    description = "The carpet extension to fix all vanilla minecraft bugs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
