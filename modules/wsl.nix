{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wsl-open
  ];

  # Set up a `systemd` service for `wsl-vpnkit`
  systemd.services.wsl-vpnkit = {
    enable = true;
    description = "wsl-vpnkit";
    after = ["network.target"];
    serviceConfig = {
      ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
      Environment = "GVPROXY_PATH=/mnt/c/Workspace/WSL/tools/gvproxy-windows.exe"; # Required because Windows security blocks execution of the executable stored inside WSL
      Restart = "always";
      KillMode = "mixed";
    };
    wantedBy = ["multi-user.target"];
  };
}
