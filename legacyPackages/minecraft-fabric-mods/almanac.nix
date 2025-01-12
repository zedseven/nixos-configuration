{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "almanac";
  version = "1.0.2+1.21";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/Gi02250Z/versions/jmiXAuhO/almanac-1.21.x-fabric-1.0.2.jar";
    hash = "sha256-VPeNqz703QGd/YaDYnSRALid37L7a2uPHooZGii2V0A=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/almanac";
    description = "Almanac is a library used by frikinjay's mods";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
