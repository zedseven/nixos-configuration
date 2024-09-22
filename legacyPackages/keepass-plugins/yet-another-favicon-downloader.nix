{
  lib,
  stdenvNoCC,
  fetchurl,
  buildEnv,
  mono,
}: let
  derivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "yet-another-favicon-downloader";
    version = "1.2.5.0";

    src = fetchurl {
      url = "https://github.com/navossoc/KeePass-Yet-Another-Favicon-Downloader/releases/download/v${finalAttrs.version}/YetAnotherFaviconDownloader.plgx";
      sha256 = "sha256-eaD6wFaaouw9QOVnjY5sbxeluYtIH5yFRSFlmZIfVe4=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = with lib; {
      homepage = "https://github.com/navossoc/KeePass-Yet-Another-Favicon-Downloader";
      description = "A plugin for KeePass 2.x that allows you to quickly download favicons for your password entries";
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
