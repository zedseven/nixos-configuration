{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "appleskin";
  version = "3.0.6+1.21";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/b5ZiCjAr/appleskin-fabric-mc1.21-3.0.6.jar";
    hash = "sha256-mhnOwSlLG8cIOSoI5pJty4XXN47FrZCaS2/Li8O/6qI=";
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
