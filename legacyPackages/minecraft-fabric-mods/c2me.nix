{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "c2me";
  version = "0.2.0+alpha.11.65+1.20.4";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/VSNURh3q/versions/9Cu1rJ2H/c2me-fabric-mc1.20.4-0.2.0+alpha.11.65.jar";
    hash = "sha256-WyqfMDC+ceVqIrUy1+ZyOlmV3jmWmwS0vv9OTU0XdtQ=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/c2me-fabric";
    description = "A Fabric mod designed to improve the chunk performance of Minecraft";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
