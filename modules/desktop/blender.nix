{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.blender = with lib; {
    enable = mkEnableOption "Blender";
  };

  config = lib.mkIf cfg.blender.enable (
    lib.mkMerge [
      {
        home-manager.users.${userInfo.username}.home.packages = with pkgs; [blender];

        # Add `blender` as a high-priority program
        custom.desktop.suckless.dwm.highPriorityPrograms = ["blender"];
      }
      (lib.mkIf (cfg.displayDriver == "nvidia") {
        # https://discourse.nixos.org/t/how-to-get-cuda-working-in-blender/5918
        environment.sessionVariables = {
          CUDA_PATH = "${pkgs.cudatoolkit}";
          EXTRA_LDFLAGS = "-L${config.hardware.nvidia.package}/lib";
        };
      })
    ]
  );
}
