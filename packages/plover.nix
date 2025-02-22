{
  lib,
  fetchFromGitHub,
  python310Packages,
  qt5,
  dbus,
  ...
}: let
  oldPackage =
    (
      (import (
        # https://github.com/NixOS/nixpkgs/pull/303669
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/FirelightFlagboy/nixpkgs/26aeb025c2777594521f94e846c04b87d0fea7ce/pkgs/applications/misc/plover/default.nix";
          sha256 = "sha256:1cif5skn19fhlknkgqxkf1c6n35y2apsnp8kzxmabdf1bmcsnsil";
        }
      ))
      {
        inherit
          lib
          fetchFromGitHub
          python310Packages
          qt5
          ;
      }
    )
    .dev;
in
  oldPackage.overridePythonAttrs (
    oldAttrs: let
      version = "4.0.0";
    in {
      inherit version;

      src = fetchFromGitHub {
        owner = "openstenoproject";
        repo = "plover";
        rev = "v${version}";
        sha256 = "sha256-9oDsAbpF8YbLZyRzj9j5tk8QGi0o1F+8vB5YLJGqN+4=";
      };

      propagatedBuildInputs =
        oldAttrs.propagatedBuildInputs
        ++ [
          python310Packages.evdev
        ];

      postPatch = ''
        # https://github.com/NixOS/nixpkgs/issues/7307#issuecomment-1232267367
        # https://discourse.nixos.org/t/screenshot-with-mss-in-python-says-no-x11-library/14534/4
        substituteInPlace plover/oslayer/linux/log_dbus.py \
          --replace-fail "ctypes.util.find_library('dbus-1')" "'${lib.makeLibraryPath [dbus]}/libdbus-1.so'"

        # https://stackoverflow.com/questions/66125129/unknownextra-error-when-installing-via-setup-py-but-not-via-pip
        substituteInPlace setup.cfg --replace-fail "plover.gui_qt.main [gui_qt]" "plover.gui_qt.main"
      '';
    }
  )
