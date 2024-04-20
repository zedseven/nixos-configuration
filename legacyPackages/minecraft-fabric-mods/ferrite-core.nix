{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ferrite-core";
  version = "6.0.3";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/uXXizFIs/versions/pguEMpy9/ferritecore-6.0.3-fabric.jar";
    hash = "sha256-ZphO6VxKsFqDxDew3QRWikosjn8hm3SYYE4llSxMwSU=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/ferrite-core";
    description = "Reduces the memory usage of Minecraft in a few different ways";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
