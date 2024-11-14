{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stitched-snow";
  version = "1.1.0";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/I095Mbn8/versions/ADwVDvSJ/stitched-snow-1.1.0.jar";
    hash = "sha256-rZUr6uPT9LRDIm46JdJKGpo6JFq/ndDhmUn6tZ/q2Ks=";
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
