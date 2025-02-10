{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  libXft,
  libXcursor,
  conf ? {},
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "dwm";
  version = "6.4";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "dwm";
    rev = "38d365ba283514549e756129970ef274ce9fb134";
    hash = "sha256-Ka+qrJMsPlRM6/JZWNQApR6g7lNQtXJiQkvAkAArYAA=";
  };

  strictDeps = true;

  buildInputs =
    [
      libX11
      libXinerama
      libXft
      libXcursor
    ]
    ++ extraLibs;

  installFlags = ["PREFIX=$(out)"];

  patches = [./configurable.patch];

  postPatch = let
    respectResizeHintsString =
      if conf.respectResizeHints
      then "1"
      else "0";
    highPriorityProgramsString = lib.concatStringsSep "," conf.highPriorityPrograms;
  in ''
    cp config.def.h config.h

    substituteInPlace config.h \
      --replace-fail "@MASTER_AREA_SIZE_PERCENTAGE@" "${(builtins.toString conf.masterAreaSizePercentage)}" \
      --replace-fail "@RESPECT_RESIZE_HINTS@" "${respectResizeHintsString}" \
      --replace-fail "@FONT_FAMILY@" "${conf.font.family}" \
      --replace-fail "@FONT_PIXEL_SIZE@" "${(builtins.toString conf.font.pixelSize)}" \
      --replace-fail "@COLOUR_GREY_1@" "${conf.colours.grey1}" \
      --replace-fail "@COLOUR_GREY_2@" "${conf.colours.grey2}" \
      --replace-fail "@COLOUR_GREY_3@" "${conf.colours.grey3}" \
      --replace-fail "@COLOUR_GREY_4@" "${conf.colours.grey4}" \
      --replace-fail "@COLOUR_ACTIVE@" "${conf.colours.active}" \
      --replace-fail "@TERMINAL_PROGRAM@" "${conf.terminalProgram}" \
      --replace-fail "@HIGH_PRIORITY_PROGRAMS@" "${highPriorityProgramsString}"

    echo "" >> config.h
    echo '''${extraConfigText}''' >> config.h
  '';

  meta = {
    homepage = "https://github.com/zedseven/dwm";
    description = "zedseven's custom fork of the Dynamic Window Manager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "dwm";
    platforms = lib.platforms.unix;
  };
}
