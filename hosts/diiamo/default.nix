# A NixOS-WSL machine, used for work.
# The name comes from the saying "a diamond in the rough" because it's a haven of declarative Linux
# running inside the mess that is Windows.
{
  nixos-wsl,
  home-manager,
  userInfo,
  ...
}: {
  imports = [
    nixos-wsl.nixosModules.wsl
    home-manager.nixosModules.home-manager
    ../../modules
    ../../user.nix
  ];

  wsl = {
    enable = true;
    defaultUser = userInfo.username;
  };

  custom.wsl.wsl-vpnkit = {
    enable = true;
    gvproxyWinPath = "/mnt/c/Workspace/WSL/tools/gvproxy-windows.exe";
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
