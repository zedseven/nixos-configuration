# Despite being primarily a client-side config API, it includes what was formerly the Auto Config mod, which
# some server-side mods still require:
# https://github.com/Fourmisain/AxesAreWeapons/issues/22#issuecomment-2935108154
# Some other mods (Appleskin, for example) include this on their own, but it's better to have it explicitly installed
{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cloth-config";
  version = "15.0.140";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/9s6osm5g/versions/HpMb5wGb/cloth-config-15.0.140-fabric.jar";
    hash = "sha256-M4lOldo69ZAUs50SZYbVJB4H6jn4YYdj4w2rY3QF+V8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/cloth-config";
    description = "Configuration Library for Minecraft Mods";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
