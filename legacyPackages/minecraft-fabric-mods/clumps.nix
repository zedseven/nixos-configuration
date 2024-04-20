{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "clumps";
  version = "15.0.0.2";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/jdeTwq6v/Clumps-fabric-1.20.4-15.0.0.2.jar";
    hash = "sha256-O52XsJp7Ta4v16xqoMBuSL5xs7PlmmmjD714oMVQoD8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/clumps";
    description = "Groups XP orbs together into a single entity to reduce lag when there are many in a small area";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
