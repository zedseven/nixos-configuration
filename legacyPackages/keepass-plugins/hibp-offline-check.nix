{
  lib,
  stdenvNoCC,
  fetchurl,
  buildEnv,
  mono,
}: let
  derivation = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "hibp-offline-check";
    version = "1.7.11";

    src = fetchurl {
      url = "https://github.com/mihaifm/HIBPOfflineCheck/releases/download/${finalAttrs.version}/HIBPOfflineCheck.plgx";
      sha256 = "sha256-ppR3YiicYnW6TJ88SCLykJvsqkkjBArEsAzkJw7/O3M=";
    };

    installPhase = ''
      mkdir -p $out/lib/dotnet/keepass/
      cp $src $out/lib/dotnet/keepass/
    '';

    dontUnpack = true;

    meta = with lib; {
      homepage = "https://github.com/mihaifm/HIBPOfflineCheck";
      description = "Keepass plugin that performs offline and online checks against HaveIBeenPwned passwords";
      license = licenses.gpl3Only;
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
