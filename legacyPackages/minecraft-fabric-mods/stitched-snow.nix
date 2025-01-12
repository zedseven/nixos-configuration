{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stitched-snow";
  version = "1.1.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/I095Mbn8/versions/vr0yDDFc/stitched-snow-1.1.1.jar";
    hash = "sha256-ks7MRYM4P6IZu9zDfWxysMnmNUebga/w3jiXyreeGKg=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/stitchedsnow";
    description = "Allows snow to stack in Minecraft";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
