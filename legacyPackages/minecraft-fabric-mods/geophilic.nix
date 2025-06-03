{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "geophilic";
  version = "3.4.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/hl5OLM95/versions/P4R9W6RV/Geophilic%20v3.4.1%20f15-71.mod.jar";
    hash = "sha256-a7x6NlE8Mr70fOnizbNy4xzY7aKoetMmdPGTZjQ+FiM=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/datapack/geophilic";
    description = "A subtle-ish overhaul of vanilla Overworld biomes";
    license = lib.licenses.unfree; # Labelled as ARR (All Rights Reserved) on Modrinth
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
