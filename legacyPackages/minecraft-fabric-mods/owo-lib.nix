{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "oωo-lib";
  version = "0.12.15+1.21";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/ccKDOlHs/versions/vCCHsvEa/owo-lib-0.12.15%2B1.21.jar";
    hash = "sha256-Bwde2DsHv3DDxKD2UvFLDo9XM7pWrhtWQcFKog9Qc8k=";
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
