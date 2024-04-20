{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "appleskin";
  version = "2.5.1+1.20.3";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/pmFyu3Sz/appleskin-fabric-mc1.20.3-2.5.1.jar";
    hash = "sha256-5N7wQUHhbiG91NOSGY7bf4ZbawmafS1ykq0FScbIZks=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/appleskin";
    description = "Adds various food-related HUD improvements"; # Needed on the server side for the client to display accurate information
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
