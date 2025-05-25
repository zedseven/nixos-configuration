{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "convenient-mobgriefing";
  version = "2.1.2+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/FJI3H6YI/versions/Yds9fTAP/convenient-mobgriefing-2.1.2.jar";
    hash = "sha256-RLsxqfzPERzfidLOEMwoHmihyn/OlXn5us0SLk8pLZc=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/convenient-mobgriefing";
    description = "Gives more control over the `mobGriefing` game rule by splitting it into four";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
