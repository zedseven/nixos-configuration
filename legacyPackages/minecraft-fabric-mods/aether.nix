{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aether";
  version = "1.5.1-beta.4+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/YhmgMVyu/versions/ZTfYLQjb/aether-1.21.1-1.5.1-beta.4-fabric.jar";
    hash = "sha256-jaB9ZbFnPj6OSDR1djIzPKPMl4ZSB+COsQotnBTmOvo=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/aether";
    description = "The Aether centers around a dimension high in the sky, filled with vast skylands of clouds and floating islands";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
