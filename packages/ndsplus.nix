# Third-party Linux software for the product: http://www.hkems.com/product/nintendo/0907.htm
{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libusb1,
}:
stdenv.mkDerivation {
  name = "ndsplus";

  src = fetchFromGitHub {
    owner = "Thulinma";
    repo = "ndsplus";
    rev = "93f517cc5a8960b21ee67a14a8a9bb1c1f578e90";
    hash = "sha256-qqI269bCEOfyxYO0wVeN/4mE1KyPzGqC6pJF8hSiup4=";
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [libusb1];

  installPhase = ''
    mkdir -p $out/bin
    cp ./ndsplus $out/bin/ndsplus
  '';

  meta = {
    homepage = "https://github.com/Thulinma/ndsplus";
    description = "Linux support for the EMS NDS Adapter+";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "ndsplus";
    platforms = lib.platforms.unix;
  };
}
