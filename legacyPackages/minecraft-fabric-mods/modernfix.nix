{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "modernfix";
  version = "5.23.0+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/nmDcB62a/versions/atkaiXFy/modernfix-fabric-5.23.0%2Bmc1.21.1.jar";
    hash = "sha256-LZctsz5al6SuKzOsYghvw2AG9JrqnG4DcIm2XHwpiV4=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/modernfix";
    description = "All-in-one mod that improves performance, reduces memory usage, and fixes many bugs";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
