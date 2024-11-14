{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "clumps";
  version = "19.0.0.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/3ene3W1l/Clumps-fabric-1.21.1-19.0.0.1.jar";
    hash = "sha256-SeQGyyhy4kotLb5GG5PwyPvuF0jRTCqUHlT3heOh4ac=";
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
