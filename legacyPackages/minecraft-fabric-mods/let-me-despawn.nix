{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "let-me-despawn";
  version = "1.2.0";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/qpC0XlcW/letmedespawn-fabric-1.20.x-1.2.0.jar";
    hash = "sha256-RxUtKz4ocNcAYNaiKIEp4UjZ01whfyrrJvSRVsCzGno=";
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
