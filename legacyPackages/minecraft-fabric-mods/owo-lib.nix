{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "oωo-lib";
  version = "0.12.15.4+1.21";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/ccKDOlHs/versions/JB1fLQnc/owo-lib-0.12.15.4%2B1.21.jar";
    hash = "sha256-glGAzhe8AS+0UGU7FN+fMkedzdBz/D8TO7R0YvWmPOw=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/owo-lib";
    description = "A general utility, GUI and config library for modding on Fabric and Quilt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
