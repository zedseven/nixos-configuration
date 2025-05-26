{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fabrication";
  version = "3.6.1+1.21";

  src = fetchurl {
    url = "https://mediafilez.forgecdn.net/files/6522/719/fabrication-3.6.1%2B1.21.jar";
    hash = "sha256-vSV0aurYET1xPbMkJH4difeh5SrfziDYja1H2HzXPfE=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://www.curseforge.com/minecraft/mc-mods/fabrication";
    description = "A large collection of vanilla tweaks and small features";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
