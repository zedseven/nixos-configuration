{
  lib,
  stdenvNoCC,
  fetchurl,
  buildEnv,
  mono,
}: let
  derivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "app-id-linker";
    version = "1.0";

    src = fetchurl {
      url = "https://github.com/zedseven/AppIdLinker/releases/download/v${finalAttrs.version}/AppIdLinker.plgx";
      sha256 = "sha256-fwDNnzI8h3h5zZxyMVQoIgQH8JmVDO4s8LYhrC7gP4U=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = with lib; {
      homepage = "https://github.com/zedseven/AppIdLinker";
      description = "A KeePass plugin for including Android app IDs in the description of entries based on their URLs";
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
