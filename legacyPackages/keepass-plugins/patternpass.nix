{
  lib,
  stdenvNoCC,
  fetchurl,
  buildEnv,
  mono,
}: let
  derivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "patternpass";
    version = "1.0";

    src = fetchurl {
      url = "https://github.com/zedseven/PatternPass/releases/download/v${finalAttrs.version}/PatternPass.plgx";
      sha256 = "sha256-PGBdVpSTsSd+8sr3CpGBpfxXTBLvLvYpNqDWGtW3ZJ0=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = with lib; {
      homepage = "https://github.com/zedseven/PatternPass";
      description = "A KeePass plugin that allows storage and viewing of pattern-based passwords (like the Android lock-screen)";
      license = licenses.mit;
      maintainers = with maintainers; [zedseven];
      platforms = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
    };
  });
in
  # Mono is required to compile the plugin at runtime, after loading
  buildEnv {
    inherit (derivation) name;

    paths = [
      mono
      derivation
    ];
  }
