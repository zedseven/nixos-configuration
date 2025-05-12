{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stitched-snow";
  version = "1.2.0";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/I095Mbn8/versions/crJKKQHh/stitched-snow-1.2.0.jar";
    hash = "sha256-sYpkwpQxO0sFbk3ftGzAXhoGf5A9RpjKveygQqrHLr4=";
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
