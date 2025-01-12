{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lithium";
  version = "0.14.3+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/9xfJi96s/lithium-fabric-0.14.3-snapshot%2Bmc1.21.1-build.92.jar";
    hash = "sha256-454v/jM/7TgzGjRAcsyXAu3PgBkrHxW8IObyqph3Mbo=";
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
