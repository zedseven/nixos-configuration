{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (
  finalAttrs: {
    pname = "lavalink-lavasrc";
    version = "4.0.1";

    src = fetchurl {
      url = "https://github.com/topi314/LavaSrc/releases/download/${finalAttrs.version}/lavasrc-plugin-${finalAttrs.version}.jar";
      hash = "sha256-JpUEpLGrRkC5ODgx57xCO4vyeILFkpKtnYTmvcSs84o=";
    };

    buildCommand = ''
      install -Dm644 $src $out/plugins/lavasrc-plugin.jar
    '';

    meta = {
      homepage = "https://github.com/topi314/LavaSrc";
      description = "A collection of additional Lavaplayer/Lavalink Sources";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [zedseven];
      platforms = lib.platforms.all;
    };
  }
)
