# Third-party software for managing WD encrypted storage devices
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  openssl,
  systemd, # Needed for `udevadm`
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wd-security";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "drafnel";
    repo = "wd-security";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UZ+VX0JYtP9L9v5zbKF4Nuo5LYqjiMx0gNe4p8L5Sn8=";
  };

  nativeBuildInputs = [autoreconfHook];

  buildInputs = [
    openssl
    systemd
  ];

  installPhase = ''
    ./wd-security --help # Runs the wrapper script so that `libtool` can generate the real binaries

    ls -lah .
    ls -lah ./.libs

    mkdir -p $out/bin
    mkdir -p $out/bin/.libs
    cp ./wd-security $out/bin/
    cp ./.libs/lt-wd-security $out/bin/.libs/
    cp ./.libs/libwd-security.so.0.0.0 $out/bin/.libs/
    ln -s libwd-security.so.0.0.0 $out/bin/.libs/libwd-security.so
    ln -s libwd-security.so.0.0.0 $out/bin/.libs/libwd-security.so.0
    cp ./wd-security-devices.sh $out/bin/

    mkdir -p $out/lib/udev/rules.d
    cp ./00-wd-security.rules $out/lib/udev/rules.d/

    RPATH=$(patchelf --print-rpath $out/bin/.libs/lt-wd-security)
    RPATH=$(echo "$RPATH" | sed "s|/build/source|$out/bin|")
    patchelf --set-rpath "$RPATH" $out/bin/.libs/lt-wd-security
  '';

  meta = {
    homepage = "https://github.com/drafnel/wd-security";
    description = "Manage password protection of Western Digital external drives supported by the proprietary WD Security software";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "wd-security";
    platforms = lib.platforms.unix;
  };
})
