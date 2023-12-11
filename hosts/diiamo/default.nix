# A NixOS-WSL machine, used for work.
# The name comes from the saying "a diamond in the rough" because it's a haven of declarative Linux
# running inside the mess that is Windows.
{
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

  services.wsl-vpnkit = {
    enable = true;
    gvproxyWinPath = "/mnt/c/Workspace/WSL/tools/gvproxy-windows.exe";
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
