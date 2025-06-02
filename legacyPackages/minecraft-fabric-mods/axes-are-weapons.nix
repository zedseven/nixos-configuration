{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "axes-are-weapons";
  version = "1.9.1+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/1jvt7RTc/versions/KdxPAtZt/AxesAreWeapons-1.9.1-fabric-1.21.jar";
    hash = "sha256-5z4xQHqCcOBFIMnLX96M+OCnL3MQum3vgycyG3AytpE=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/axes-are-weapons";
    description = "Disables the increased durability loss in combat and enables Looting for axes and more";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
