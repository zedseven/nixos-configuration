{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lithium";
  version = "0.12.1+1.20.4";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/nMhjKWVE/lithium-fabric-mc1.20.4-0.12.1.jar";
    hash = "sha256-as1JWV7mnhJkz8eYmPVpRS5BvWaYVGf8s40oBBka880=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/lithium";
    description = "No-compromises game logic/server optimization mod";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
