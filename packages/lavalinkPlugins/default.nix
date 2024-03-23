{
  pkgs,
  lib,
  ...
}:
lib.makeScope pkgs.newScope (
  self: let
    inherit (self) callPackage;
  in {
    dunctebot = callPackage ./dunctebot.nix {};
    lavasrc = callPackage ./lavasrc.nix {};
  }
)
