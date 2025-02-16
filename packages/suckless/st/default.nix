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
  conf ? {
    shell = "/bin/sh";
    font = {
      family = "Liberation Mono";
      pixelSize = 12;
      characterTweaks = {
        widthScale = 1.0;
        heightScale = 1.0;
        xOffset = 0;
        yOffset = 0;
      };
    };
    colourSchemeText = ''
      /* Terminal colors (first 16 used in escape sequence) */
      static const char *colorname[] = {
        /* 8 normal colors */
        "black",
        "red3",
        "green3",
        "yellow3",
        "blue2",
        "magenta3",
        "cyan3",
        "gray90",

        /* 8 bright colors */
        "gray50",
        "red",
        "green",
        "yellow",
        "#5c5cff",
        "magenta",
        "cyan",
        "white",

        [255] = 0,

        /* more colors can be added after 255 to use with DefaultXX */
        "#cccccc",
        "#555555",
        "gray90", /* default foreground colour */
        "black", /* default background colour */
      };

      /*
       * Default colors (colorname index)
       * foreground, background, cursor, reverse cursor
       */
      unsigned int defaultfg = 258;
      unsigned int defaultbg = 259;
      unsigned int defaultcs = 256;
      static unsigned int defaultrcs = 257;
    '';
  },
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "st";
  version = "0.9.2-custom";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "st";
    rev = "1aeed899de950fcb125a15854de68d5a7c627afd";
    hash = "sha256-jBOTfRdAnVpdIteMOmi8SQ0G1Xq0E01LHNfqh9tB3W4=";
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
