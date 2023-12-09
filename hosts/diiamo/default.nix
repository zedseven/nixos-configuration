# A NixOS-WSL machine, used for work.
# The name comes from the saying "a diamond in the rough" because it's a haven of declarative Linux
# running inside the mess that is Windows.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    <nixos-wsl/modules>
    <home-manager/nixos>
    ../../modules/global.nix
    ../../modules/wsl.nix
    ../../zacc.nix
  ];

  environment = {
    etc."nixos".source = "/home/zacc/nix";
  };

  networking.hostName = "diiamo";

  wsl = {
    enable = true;
    defaultUser = "zacc";
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
