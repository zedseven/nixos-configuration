{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  file,
  getopt,
  patchelf,
}:
stdenv.mkDerivation {
  name = "autopatchelf";

  src = fetchFromGitHub {
    owner = "svanderburg";
    repo = "nix-patchtools";
    rev = "6cc6fa4e0d8e1f24be155f6c60af34c8756c9828";
    hash = "sha256-anuSZw0wcKtTxszBZh2Ob/eOftixEZzrNC1sCaQzznk=";
  };

  # Copied from the following location, since the `default.nix` file provided has an impure import:
  # https://github.com/svanderburg/nix-patchtools/blob/6cc6fa4e0d8e1f24be155f6c60af34c8756c9828/default.nix#L3-L13
  buildCommand = ''
    mkdir -p $out/bin
    cp $src/autopatchelf $out/bin/autopatchelf
    substituteInPlace $out/bin/autopatchelf \
      --replace "file " "${file}/bin/file " \
      --replace "getopt " "${getopt}/bin/getopt " \
      --replace "patchelf " "${patchelf}/bin/patchelf "
    chmod +x $out/bin/autopatchelf
    patchShebangs $out/bin
  '';

  meta = {
    homepage = "https://github.com/svanderburg/nix-patchtools";
    description = "Autopatching binary packages to make them work with Nix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "autopatchelf";
    platforms = lib.platforms.unix;
  };
}
