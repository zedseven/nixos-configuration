# Mostly sourced from the unmerged fork for https://github.com/NixOS/nixpkgs/pull/303669
{
  lib,
  fetchFromGitHub,
  # Plover is currently tested with python 3.10 and do not seems to work with more recent versions
  # https://github.com/openstenoproject/plover/commits/a8ac3631bee1971eec2b41b74fbebdad4750291a
  python310Packages,
  qt5,
  dbus,
  ...
}: let
  plover_stroke = python310Packages.buildPythonPackage (
    let
      version = "1.1.0";
    in {
      pname = "plover_stroke";
      inherit version;

      pyproject = true;

      src = fetchFromGitHub {
        owner = "openstenoproject";
        repo = "plover_stroke";
        rev = "${version}";
        hash = "sha256-A75OMzmEn0VmDAvmQCp6/7uptxzwWJTwsih3kWlYioA=";
      };

      propagatedBuildInputs = with python310Packages; [setuptools];

      nativeCheckInputs = with python310Packages; [pytestCheckHook];
      pythonImportsCheck = ["plover_stroke"];

      meta = {
        description = "Stroke handling helper library for Plover";
        license = lib.licenses.gpl2Plus;
        homepage = "https://github.com/openstenoproject/plover_stroke";
        platforms = lib.platforms.linux ++ lib.platforms.windows;
        maintainers = with lib.maintainers; [zedseven];
      };
    }
  );

  rtf_tokenize = python310Packages.buildPythonPackage (
    let
      version = "1.0.0";
    in {
      pname = "rtf_tokenize";
      inherit version;

      pyproject = true;

      src = fetchFromGitHub {
        owner = "openstenoproject";
        repo = "rtf_tokenize";
        rev = "${version}";
        hash = "sha256-zwD2sRYTY1Kmm/Ag2hps9VRdUyQoi4zKtDPR+F52t9A=";
      };

      propagatedBuildInputs = with python310Packages; [setuptools];

      nativeCheckInputs = with python310Packages; [pytestCheckHook];
      pythonImportsCheck = ["rtf_tokenize"];

      meta = {
        description = "Simple RTF tokenizer";
        license = lib.licenses.gpl2Plus;
        homepage = "https://github.com/openstenoproject/rtf_tokenize";
        platforms = lib.platforms.linux ++ lib.platforms.windows;
        maintainers = with lib.maintainers; [zedseven];
      };
    }
  );
in
  python310Packages.buildPythonPackage (
    let
      version = "4.0.0";
    in {
      pname = "plover";
      inherit version;

      pyproject = true;

      src = fetchFromGitHub {
        owner = "openstenoproject";
        repo = "plover";
        rev = "v${version}";
        hash = "sha256-9oDsAbpF8YbLZyRzj9j5tk8QGi0o1F+8vB5YLJGqN+4=";
      };

      nativeBuildInputs = with python310Packages; [
        setuptools
        qt5.wrapQtAppsHook
      ];

      propagatedBuildInputs = with python310Packages; [
        babel
        pyqt5
        xlib
        pyserial
        appdirs
        wcwidth
        setuptools
        evdev
        plover_stroke
        rtf_tokenize
      ];

      buildInputs = [qt5.qtwayland];

      nativeCheckInputs = with python310Packages; [
        pytestCheckHook
        pytest-qt
      ];

      postPatch = ''
        # https://github.com/NixOS/nixpkgs/issues/7307#issuecomment-1232267367
        # https://discourse.nixos.org/t/screenshot-with-mss-in-python-says-no-x11-library/14534/4
        substituteInPlace plover/oslayer/linux/log_dbus.py \
          --replace-fail "ctypes.util.find_library('dbus-1')" "'${lib.makeLibraryPath [dbus]}/libdbus-1.so'"

        # https://stackoverflow.com/questions/66125129/unknownextra-error-when-installing-via-setup-py-but-not-via-pip
        substituteInPlace setup.cfg --replace-fail "plover.gui_qt.main [gui_qt]" "plover.gui_qt.main"
      '';

      preCheck = ''
        export HOME=$(mktemp -d)
        export QT_PLUGIN_PATH="${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}"
        export QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins";
        export QT_QPA_PLATFORM=offscreen
      '';

      dontWrapQtApps = true;

      preFixup = ''
        makeWrapperArgs+=("''${qtWrapperArgs[@]}")
      '';

      meta = {
        mainProgram = "plover";
        broken = python310Packages.stdenv.hostPlatform.isDarwin;
        description = "OpenSteno Plover stenography software";
        homepage = "https://www.openstenoproject.org/plover/";
        maintainers = with lib.maintainers; [zedseven];
        license = lib.licenses.gpl2Plus;
      };
    }
  )
