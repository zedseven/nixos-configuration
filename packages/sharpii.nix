{
  lib,
  stdenv,
  fetchurl,
  openssl,
  zlib,
}:
stdenv.mkDerivation {
  pname = "sharpii";
  version = "1.7.3";

  src = fetchurl {
    url = "https://naim2000.github.io/res/exe/Sharpii/sharpii(linux-x64)";
    hash = "sha256-xBQrGRHWSfXkoqrXqZNi9qOJmzbLo97yaaFgazXvesA=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/sharpii

    runHook postInstall
  '';

  #autoPatchelfHook breaks the binary for some reason
  fixupPhase = ''
    runHook preFixup

    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $out/bin/sharpii
    patchelf --set-rpath ${stdenv.cc.libc}/lib $out/bin/sharpii
    patchelf --add-rpath ${stdenv.cc.cc.lib}/lib $out/bin/sharpii
    patchelf --add-rpath ${zlib}/lib $out/bin/sharpii
    patchelf --add-rpath ${openssl}/lib $out/bin/sharpii

    runHook postFixup
  '';

  meta = {
    homepage = "https://github.com/mogzol/sharpii";
    description = "A command-line application for downloading from the NUS and managing Nintendo Wii files";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "sharpii";
    platforms = lib.platforms.unix;
  };
}
