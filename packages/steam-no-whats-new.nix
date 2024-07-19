{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnugrep,
  gnused,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "steam-no-whats-new";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mchangrh";
    repo = "NoWhatsNew";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RZ4fw1nQE9Y6YRowvPWnCAZDR+zZY/lOolxSRvc8GaM=";
  };

  postPatch = ''
    substituteInPlace patch.sh \
    --replace "grep " "${gnugrep}/bin/grep " \
    --replace "sed " "${gnused}/bin/sed "
  '';

  preInstall = ''
    mkdir -p $out/bin
    install -Dm755 patch.sh $out/bin/patch.sh
  '';

  meta = {
    homepage = "https://github.com/mchangrh/NoWhatsNew";
    description = ''Script to remove Steam Library "What's New"'';
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "patch.sh";
    platforms = lib.platforms.unix;
  };
})
