{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lithium";
  version = "0.15.0+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/MM5BBBOK/lithium-fabric-0.15.0%2Bmc1.21.1.jar";
    hash = "sha256-1f6NMZXqxbLN/6AO1+MHdWDGTSBkuIIhzeoNntBQBLY=";
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
