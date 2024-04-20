{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "carpet-extra";
  version = "1.4.128";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/APnGg1O6/carpet-extra-1.20.3-1.4.128.jar";
    hash = "sha256-3VyUCdt+OkFkqNPQTEaNyt/kX86W9glibsWD7FWpvD8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/carpet-extra";
    description = "An extension adding extra features to Carpet";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
