{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "carpet";
  version = "1.4.128";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/yYzR60Xd/fabric-carpet-1.20.3-1.4.128+v231205.jar";
    hash = "sha256-2OXPIYSEj9eNSC8jVU7YFNsglKzTf6ti2M5zedO6Aso=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/carpet";
    description = "A mod for vanilla Minecraft that allows you to take full control of what matters from a technical perspective of the game";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
