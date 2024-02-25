{
  pkgs,
  lib,
}:
lib.makeScope pkgs.newScope (
  self: let
    inherit (self) callPackage;
  in {
    lavasrc = callPackage ./lavasrc.nix {};
    skybot = callPackage ./skybot.nix {};
  }
)
