{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.wsl-vpnkit;
in {
  options.services.wsl-vpnkit = with lib; {
    enable = mkEnableOption "Whether to set up `wsl-vpnkit` as a service.";
    gvproxyWinPath = mkOption {
      # This is a string instead of a path so that Nix does not copy it to the Nix store
      # If Nix copies the executable to the Nix store, it gets run from within WSL, defeating the whole point
      type = types.nullOr types.str;
      description = mdDoc ''
        The path to the Windows version of `gvproxy`, `gvproxy-windows.exe`.

        The Nix derivation for `wsl-vpnkit` creates it but on some Windows systems, Windows' security
        settings block execution of the executable from within the WSL directory.

        This option defines the path to a copy of the executable on the Windows installation.
      '';
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        wsl-open
      ];
    }
    (lib.mkIf cfg.enable {
      # Set up a `systemd` service for `wsl-vpnkit`
      # Based on `wsl-vpnkit.service` from `wsl-vpnkit`
      systemd.services.wsl-vpnkit = {
        enable = true;
        description = "wsl-vpnkit";
        after = ["network.target"];
        serviceConfig = lib.mkMerge [
          {
            ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
            Restart = "always";
            KillMode = "mixed";
          }
          (lib.mkIf (cfg.gvproxyWinPath != null) {
            Environment = "GVPROXY_PATH=${cfg.gvproxyWinPath}";
          })
        ];
        wantedBy = ["multi-user.target"];
      };
    })
  ];
}
