{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stitched-snow";
  version = "1.0.7";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/I095Mbn8/versions/sdnCn9Zp/stitched-snow-1.0.7.jar";
    hash = "sha256-mJXW/VCPBvxPPZWLZ3htMeXhjKNV4lWLkMpPkY92buY=";
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
