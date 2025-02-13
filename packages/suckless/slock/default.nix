{
  lib,
  stdenv,
  fetchFromGitHub,
  xorgproto,
  libX11,
  libXext,
  libXrandr,
  libxcrypt,
  conf ? {
    user = "nobody";
    group = "nogroup";
    failOnClear = true;
    controlKeyClear = false;
    monitorOffSeconds = 5;
    quickCancelSeconds = 4;
    quickCancelEnabledByDefault = true;
    commands = {
      "shutdown" = "doas poweroff";
    };
    colours = {
      initialisation = "#000000";
      input = "#005577";
      failed = "#cc3333";
      capsLock = "#007755";
    };
  },
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "slock";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "slock";
    rev = "84c9d2702e94cf45bd0049cd430755613e6dfbd3";
    hash = "sha256-BnS/lKWgRpjxsGDWMflPfgrFQeuTiT5gXvg2cztxlYE=";
  };

  strictDeps = true;

  buildInputs =
    [
      xorgproto
      libX11
      libXext
      libXrandr
      libxcrypt
    ]
    ++ extraLibs;

  installFlags = ["PREFIX=$(out)"];

  patches = [./configurable.patch];

  postPatch = let
    failOnClearString =
      if conf.failOnClear
      then "1"
      else "0";
    controlKeyClearString =
      if conf.controlKeyClear
      then "1"
      else "0";
    quickCancelEnabledByDefaultString =
      if conf.quickCancelEnabledByDefault
      then "1"
      else "0";
    commandsString = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (password: command: "{ \"${password}\", \"${command}\" },") conf.commands
    );
  in ''
    sed -i '/chmod u+s/d' Makefile

    cp config.def.h config.h

    COMMANDS_TEXT=$(cat <<-END
      ${commandsString}
    END
    )

    substituteInPlace config.h \
      --replace-fail "@USER@" "${conf.user}" \
      --replace-fail "@GROUP@" "${conf.group}" \
      --replace-fail "@FAIL_ON_CLEAR@" "${failOnClearString}" \
      --replace-fail "@CONTROL_KEY_CLEAR@" "${controlKeyClearString}" \
      --replace-fail "@MONITOR_OFF_SECONDS@" "${(builtins.toString conf.monitorOffSeconds)}" \
      --replace-fail "@QUICK_CANCEL_SECONDS@" "${(builtins.toString conf.quickCancelSeconds)}" \
      --replace-fail "@QUICK_CANCEL_ENABLED_BY_DEFAULT@" "${quickCancelEnabledByDefaultString}" \
      --replace-fail "@COMMANDS@" "''$COMMANDS_TEXT" \
      --replace-fail "@COLOUR_INITIALISATION@" "${conf.colours.initialisation}" \
      --replace-fail "@COLOUR_INPUT@" "${conf.colours.input}" \
      --replace-fail "@COLOUR_FAILED@" "${conf.colours.failed}" \
      --replace-fail "@COLOUR_CAPS_LOCK@" "${conf.colours.capsLock}"

    echo "" >> config.h
    echo '''${extraConfigText}''' >> config.h
  '';

  meta = {
    homepage = "https://github.com/zedseven/slock";
    description = "zedseven's custom fork of the simple display locker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "slock";
    platforms = lib.platforms.unix;
  };
}
