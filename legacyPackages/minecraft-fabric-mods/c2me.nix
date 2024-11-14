{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "c2me";
  version = "0.3.0+alpha.0.295+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/VSNURh3q/versions/4Dtxhzpd/c2me-fabric-mc1.21.1-0.3.0%2Balpha.0.295.jar";
    hash = "sha256-CroOUi/YnPz5kXSy6dX6Y5BOlAdN0g5+zLbMTpUMISM=";
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
