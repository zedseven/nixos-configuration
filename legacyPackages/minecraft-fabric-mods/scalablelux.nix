{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "scalablelux";
  version = "0.1.0";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/Oh80nTJ5/ScalableLux-0.1.0%2Bfabric.26c6e72-all.jar";
    hash = "sha256-Q/SnqtT3LF1v/Xkn7HFWRLA/KlZEuz3vnx1PCakFSMo=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/scalablelux";
    description = "A Fabric mod based on Starlight that improves the performance of light updates in Minecraft";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
