{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lavalink-dunctebot"; # The name is ambiguous between `dunctebot` and `skybot` - `dunctebot` was chosen because that's what the configuration uses
  version = "1.6.3";

  src = fetchurl {
    url = "https://github.com/DuncteBot/skybot-lavalink-plugin/releases/download/${finalAttrs.version}/skybot-lavalink-plugin-${finalAttrs.version}.jar";
    hash = "sha256-4ZfcDTghCZEEbBW5QQoZFySa2dkPkCU6c30eTQSaRR0=";
  };

  buildCommand = ''
    install -Dm644 $src $out/plugins/skybot-lavalink-plugin.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://github.com/DuncteBot/skybot-lavalink-plugin";
    description = "Lavalink plugin adding support for several audio source managers";
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
