{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  ncurses,
  fontconfig,
  freetype,
  libX11,
  libXft,
  libXcursor,
  harfbuzz,
  conf ? {},
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "st";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "st";
    rev = "54d82a8156a1bee8ebfec5836c3325490259fca3";
    hash = "sha256-n91/Evy9RuUXF+G5gbwm/7eKvMwVMKg/pBgl6rX9UZg=";
  };

  outputs = [
    "out"
    "terminfo"
  ];

  strictDeps = true;

  makeFlags = ["PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"];

  nativeBuildInputs = [
    pkg-config
    ncurses
    fontconfig
    freetype
  ];

  buildInputs =
    [
      libX11
      libXft
      libXcursor
      harfbuzz
    ]
    ++ extraLibs;

  installFlags = ["PREFIX=$(out)"];

  patches = [./configurable.patch];

  postPatch = ''
    cp config.def.h config.h

    COLOUR_SCHEME_TEXT=$(cat <<-END
      ${conf.colourSchemeText}
    END
    )

    substituteInPlace config.h \
      --replace-fail "@SHELL@" "${conf.shell}" \
      --replace-fail "@FONT_FAMILY@" "${conf.font.family}" \
      --replace-fail "@FONT_PIXEL_SIZE@" "${(builtins.toString conf.font.pixelSize)}" \
      --replace-fail "@FONT_CHARACTER_TWEAKS_WIDTH_SCALE@" "${(builtins.toString conf.font.characterTweaks.widthScale)}" \
      --replace-fail "@FONT_CHARACTER_TWEAKS_HEIGHT_SCALE@" "${(builtins.toString conf.font.characterTweaks.heightScale)}" \
      --replace-fail "@FONT_CHARACTER_TWEAKS_X_OFFSET@" "${(builtins.toString conf.font.characterTweaks.xOffset)}" \
      --replace-fail "@FONT_CHARACTER_TWEAKS_Y_OFFSET@" "${(builtins.toString conf.font.characterTweaks.yOffset)}" \
      --replace-fail "@COLOUR_SCHEME@" "''$COLOUR_SCHEME_TEXT"

    echo "" >> config.h
    echo '''${extraConfigText}''' >> config.h
  '';

  preInstall = ''
    export TERMINFO=$terminfo/share/terminfo
    mkdir -p $TERMINFO $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  meta = {
    homepage = "https://github.com/zedseven/st";
    description = "zedseven's custom fork of the Simple Terminal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "st";
    platforms = lib.platforms.unix;
  };
}
