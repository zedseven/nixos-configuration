{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hearths";
  version = "1.0.3";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/XCIMrYn0/versions/3PlqEnzz/Hearths%20v1.0.3%20f12-71.jar";
    hash = "sha256-62doRo4WSj9niShFTqNN5shWjr9FuP6eIGi+IcNINQo=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/datapack/hearths";
    description = "A handful of additions to vanilla Nether biomes";
    license = lib.licenses.unfree; # Labelled as ARR (All Rights Reserved) on Modrinth
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
