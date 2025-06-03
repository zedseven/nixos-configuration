{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "explorify";
  version = "1.6.2";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/HSfsxuTo/versions/yRSH0sWM/Explorify%20v1.6.2%20f10-48.jar";
    hash = "sha256-goDdSz+polo03WY8Pg3GNCunkq4xq5fXXDwg5EvMLfU=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/datapack/explorify";
    description = "A simplistic, vanilla-friendly collection of new structures";
    license = lib.licenses.unfree; # Labelled as ARR (All Rights Reserved) on Modrinth
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
