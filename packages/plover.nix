{
  lib,
  fetchFromGitHub,
  python310Packages,
  qt5,
  ...
} @ arguments: let
  oldPackage =
    (
      (import (
        # https://github.com/NixOS/nixpkgs/pull/303669
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/FirelightFlagboy/nixpkgs/26aeb025c2777594521f94e846c04b87d0fea7ce/pkgs/applications/misc/plover/default.nix";
          sha256 = "sha256:1cif5skn19fhlknkgqxkf1c6n35y2apsnp8kzxmabdf1bmcsnsil";
        }
      ))
      arguments
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
    }
  )
