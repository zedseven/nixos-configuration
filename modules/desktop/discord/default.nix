# Mainly sourced from https://github.com/NixOS/nixpkgs/issues/195512#issuecomment-1814318443
# and https://github.com/sersorrel/sys/blob/main/hm/discord/default.nix
# Additional changes have been made to re-install BetterDiscord on every launch
{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.discord;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.discord = {
    enable = lib.mkEnableOption "Discord";
    wrapDiscord = lib.mkEnableOption "a wrapped version of Discord with several customisations";
  };

  config = lib.mkIf cfg.enable (
    let
      krispPatcher = pkgs.writers.writePython3Bin "discord-krisp-patcher" {
        libraries = with pkgs.python3Packages; [
          pyelftools
          capstone
        ];
        flakeIgnore = [
          "E265" # from nix-shell shebang
          "E501" # line too long (82 > 79 characters)
          "F403" # `from module import *` used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      } (builtins.readFile ./krisp-patcher.py);

      # The bin name must be something other than `discord` because `betterdiscordctl` will kill all processes
      # by that name as part of the `uninstall` command
      discordWrapped = pkgs.writeShellScriptBin "discord-better" ''
        ${pkgs.betterdiscordctl}/bin/betterdiscordctl uninstall
        ${pkgs.betterdiscordctl}/bin/betterdiscordctl install
        ${pkgs.findutils}/bin/find -L $HOME/.config/discord -name 'discord_krisp.node' -exec ${krispPatcher}/bin/discord-krisp-patcher {} +
        ${pkgs.discord}/bin/discord "$@"
      '';
    in {
      home-manager.users.${userInfo.username}.home.packages =
        [
          krispPatcher
        ]
        ++ (
          if cfg.wrapDiscord
          then [discordWrapped]
          else [pkgs.discord]
        );

      nixpkgs.config.packageOverrides = pkgs: {
        discord = pkgs.discord.overrideAttrs {withOpenASAR = true;};
      };
    }
  );
}
