{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "c2me";
  version = "0.3.0+alpha.0.320+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/VSNURh3q/versions/oXr69pco/c2me-fabric-mc1.21.1-0.3.0%2Balpha.0.320.jar";
    hash = "sha256-IDh922nwpTzo1sPUr2DY2Mx8ldgZuJjwf6zc0U2WZiA=";
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
