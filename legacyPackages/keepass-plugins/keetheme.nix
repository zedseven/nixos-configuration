{
  lib,
  stdenvNoCC,
  fetchurl,
  buildEnv,
  mono,
}: let
  derivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "keetheme";
    version = "0.10.7";

    src = fetchurl {
      url = "https://github.com/xatupal/KeeTheme/releases/download/v${finalAttrs.version}/KeeTheme.plgx";
      sha256 = "sha256-SxMai1jwydyiWf+RXmN0BxUcz8Oft/pPyc8HfcnF/5Y=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = with lib; {
      homepage = "https://github.com/xatupal/KeeTheme";
      description = "Changes the appearance of KeePass, to make it look better at night";
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
