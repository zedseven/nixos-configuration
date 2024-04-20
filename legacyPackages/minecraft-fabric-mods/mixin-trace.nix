{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mixin-trace";
  version = "1.1.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/sGmHWmeL/versions/1.1.1+1.17/mixintrace-1.1.1+1.17.jar";
    hash = "sha256-JsohoncGz6RWGGjzHE/QfFQujMdZQZ9YhN3/HzoSapk=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/mixintrace";
    description = "Adds a list of mixins in the stack trace to crash reports";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
