{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "memory-leak-fix";
  version = "1.1.5+1.17+";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/memoryleakfix-fabric-1.17+-1.1.5.jar";
    hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/memoryleakfix";
    description = "A mod that fixes random memory leaks for both the client and server";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
