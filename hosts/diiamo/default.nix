# A NixOS-WSL machine, used for work.
# The name comes from the saying "a diamond in the rough" because it's a haven of declarative Linux
# running inside the mess that is Windows.
{
  inputs,
  userInfo,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.home-manager.nixosModules.home-manager
    ../../modules
  ];

  wsl = {
    enable = true;
    defaultUser = userInfo.username;
  };

  custom = {
    user.type = "full";

    wsl = {
      enable = true;
      wsl-vpnkit = {
        enable = true;
        gvproxyWinPath = "/mnt/c/Workspace/WSL/tools/gvproxy-windows.exe";
      };
    };
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
