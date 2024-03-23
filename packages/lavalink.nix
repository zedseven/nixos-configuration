{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  jre,
  ...
}:
stdenvNoCC.mkDerivation (
  finalAttrs: {
    pname = "lavalink";
    version = "4.0.3";

    src = fetchurl {
      url = "https://github.com/lavalink-devs/Lavalink/releases/download/${finalAttrs.version}/Lavalink.jar";
      hash = "sha256-wdL1mKr+cC5k3Yw69Xz2C7yGQUQvlAjEhkfnl4fkIRE=";
    };

    nativeBuildInputs = [makeWrapper];

    buildCommand = ''
      install -Dm644 $src $out/lib/Lavalink.jar

      mkdir -p $out/bin
      makeWrapper ${jre}/bin/java $out/bin/lavalink \
        --add-flags "-jar $out/lib/Lavalink.jar"
    '';

    meta = {
      homepage = "https://lavalink.dev/";
      description = "Standalone audio sending node based on Lavaplayer";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [zedseven];
      mainProgram = "lavalink";
      platforms = lib.platforms.all;
    };
  }
)
