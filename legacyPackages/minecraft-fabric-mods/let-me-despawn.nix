{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "let-me-despawn";
  version = "1.4.4";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/e0AXgTFp/letmedespawn-1.21.x-fabric-1.4.4.jar";
    hash = "sha256-TTXnoq5R6EX7zBUscbMtonOBYO3zSvDtDg/XqWGkZMg=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/plugin/lmd";
    description = "Improves performance by tweaking mob despawn rules";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
