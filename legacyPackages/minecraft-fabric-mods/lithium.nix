{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lithium";
  version = "0.13.1+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/9x0igjLz/lithium-fabric-mc1.21.1-0.13.1.jar";
    hash = "sha256-H0OFqO4sBORv2s36P3UdF/U9H0wjMviJQjCObcK2lPY=";
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
