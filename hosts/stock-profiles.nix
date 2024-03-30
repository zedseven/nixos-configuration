# Enables stock profiles from `nixpkgs` based on inputs.
# https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
{
  modulesPath,
  isServer,
  ...
}: {
  imports = let
    profilePaths = map (profile: (modulesPath + "/profiles/" + profile));
  in (
    if isServer
    then
      profilePaths [
        "headless.nix"
        "minimal.nix"
      ]
    else []
  );
}
