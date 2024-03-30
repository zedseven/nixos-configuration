# Enables stock profiles from `nixpkgs` based on inputs.
# https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
{
  lib,
  modulesPath,
  isServer,
  ...
}: {
  imports = let
    profilePaths = map (profile: (modulesPath + "/profiles/" + profile));
  in (lib.optionals isServer (
    profilePaths [
      "headless.nix"
      "minimal.nix"
    ]
  ));
}
