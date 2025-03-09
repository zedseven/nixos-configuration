{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  libXft,
  libXcursor,
  conf ? {
    rules = [];
    masterAreaSizePercentage = 0.55;
    respectResizeHints = false;
    font = {
      family = "monospace";
      pixelSize = 10;
    };
    colours = {
      grey1 = "#222222";
      grey2 = "#444444";
      grey3 = "#bbbbbb";
      grey4 = "#eeeeee";
      active = "#005577";
    };
    terminalProgram = "st";
    highPriorityPrograms = [];
  },
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "dwm";
  version = "6.5-custom";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "dwm";
    rev = "b155060dc0ec46db624f26fcff07f64d3314a681";
    hash = "sha256-BmqjHWvuB+ac1/Fu1tjs2VHyCpIUq2h0pW2NcXZK9Hg=";
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
    codeStringOrNull = value:
      if value == null
      then "NULL"
      else "\"${value}\"";
    boolAsIntString = value:
      if value
      then "1"
      else "0";
    rulesString = lib.concatStringsSep "\n" (
      map (
        rule: let
          tagString =
            if rule.tagIndices == []
            then "0"
            else lib.concatStringsSep " | " (map (tagIndex: "(1 << ${builtins.toString tagIndex})") rule.tagIndices);
          monitorIndexString =
            if rule.monitorIndex == null
            then "-1"
            else builtins.toString rule.monitorIndex;
        in "{ ${(codeStringOrNull rule.class)}, ${(codeStringOrNull rule.instance)}, ${(codeStringOrNull rule.title)}, ${tagString}, ${(boolAsIntString rule.isFloating)}, ${monitorIndexString} },"
      )
      conf.rules
    );
    highPriorityProgramsString = lib.concatStringsSep "," conf.highPriorityPrograms;
  in ''
    cp config.def.h config.h

    RULES_TEXT=$(cat <<-END
      ${rulesString}
    END
    )

    substituteInPlace config.h \
      --replace-fail "@RULES@" "''$RULES_TEXT" \
      --replace-fail "@MASTER_AREA_SIZE_PERCENTAGE@" "${(builtins.toString conf.masterAreaSizePercentage)}" \
      --replace-fail "@RESPECT_RESIZE_HINTS@" "${(boolAsIntString conf.respectResizeHints)}" \
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
