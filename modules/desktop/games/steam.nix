{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  system,
  ...
}: let
  cfg = config.custom.desktop.games.steam;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.games.steam = with lib; {
    enable = mkEnableOption "Steam";
    wrapSteam = mkEnableOption "a wrapped version of Steam with customisations";
  };

  config = lib.mkIf cfg.enable (
    let
      # https://gist.github.com/shmup/4e7050d50e1db2e9fc4071bf31efa934
      protonRun = pkgs.writeShellScriptBin "proton-run" ''
        if [[ "$#" -ne 1 ]]; then
            echo "HELP: Usage: $0 <EXECUTABLE_PATH>"
            exit 1
        fi

        PROTON_ROOT="$HOME/.proton"
        STEAM_ROOT="$HOME/.steam/root"
        PROTON_VER="Proton - Experimental"
        GAME_ROOT="$(dirname "$1")"
        GAME="$(basename "$1")"

        cd "$GAME_ROOT" || exit

        mkdir -p "$PROTON_ROOT/$GAME"
        export STEAM_COMPAT_DATA_PATH="$PROTON_ROOT/$GAME"
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_ROOT"

        "$STEAM_ROOT/steamapps/common/$PROTON_VER/proton" run "$1" >/dev/null 2>&1
      '';
    in
      lib.mkMerge [
        {
          programs.steam.enable = true;
          hardware.steam-hardware.enable = true;

          # Used for running Proton games with different environment variables
          home-manager.users.${userInfo.username}.home.packages = with pkgs; [
            gamemode
            protonRun
          ];

          custom = {
            # Add `steam` as a high-priority program
            desktop.suckless.dwm.highPriorityPrograms = ["steam"];

            # Install `pyroveil` as a Vulkan layer for applying hacks to games to work around driver bugs
            symlinks."/home/${userInfo.username}/.local/share/vulkan/implicit_layer.d/VkLayer_pyroveil_64.json".source = "${inputs.self.packages.${system}.pyroveil}/share/vulkan/implicit_layer.d/VkLayer_pyroveil_64.json";
          };
        }
        (lib.mkIf cfg.wrapSteam (
          let
            # Wraps Steam with a patcher that removes the `What's New` section of the library
            steamWrapped = pkgs.writeShellScriptBin "steam" ''
              ${inputs.self.packages.${system}.steam-no-whats-new}/bin/patch.sh
              ${config.programs.steam.package}/bin/steam "$@"
            '';
          in {
            home-manager.users.${userInfo.username}.home.packages = [steamWrapped];
          }
        ))
      ]
  );
}
