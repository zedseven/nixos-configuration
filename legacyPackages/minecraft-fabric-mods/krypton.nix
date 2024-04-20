{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "krypton";
  version = "0.2.6";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/bRcuOnao/krypton-0.2.6.jar";
    hash = "sha256-cgJMTT+ojERKtDoG917YQDsgExxHJfT/Zm34scpR6xU=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/krypton";
    description = "A mod to optimize the Minecraft networking stack";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
