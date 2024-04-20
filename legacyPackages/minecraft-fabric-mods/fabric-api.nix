{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fabric-api";
  version = "0.97.0+1.20.4";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/xklQBMta/fabric-api-0.97.0+1.20.4.jar";
    hash = "sha256-/MwBE2Y5JUC3n7JhBsRHysz5sr24JU6COnngfC7dp4Y=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/fabric-api";
    description = "Essential hooks for modding with Fabric";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
