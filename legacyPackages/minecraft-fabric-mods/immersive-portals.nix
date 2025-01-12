{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "immersive-portals";
  version = "6.0.6+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/zJpHMkdD/versions/vOmUATGw/immersive-portals-6.0.6-mc1.21.1-fabric.jar";
    hash = "sha256-B8ledCLDEbU8CCpZjdUzFp1y+ybug4XmmCzHB4yfeXk=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/immersiveportals";
    description = "See through portals and teleport seamlessly";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
