# Mainly for the MiniHUD client-side mod
# Client-side mods by `masa` that I want to mention here (since they aren't required on the server):
# - Item Scroller
# - Litematica
# - MiniHUD
# - Tweakeroo
{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "servux";
  version = "0.3.13+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/B6Y1CK8z/servux-fabric-1.21-0.3.13.jar";
    hash = "sha256-Qsq9Nh6fDHoY/oDFkQK5cRjmVzIeVMoIQDw0Z++vlGA=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/servux";
    description = "A server-side mod that provides support for some client-side mods, such as sending structure bounding boxes for MiniHUD";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
