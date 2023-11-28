# Mainly sourced from https://github.com/NixOS/nixpkgs/issues/195512#issuecomment-1814318443
# and https://github.com/sersorrel/sys/blob/main/hm/discord/default.nix
# Additional changes have been made to re-install BetterDiscord on every launch
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.discord;

  discordPatcherBin = pkgs.writers.writePython3Bin "discord-krisp-patcher" {
    libraries = with pkgs.python3Packages; [pyelftools capstone];
    flakeIgnore = [
      "E265" # from nix-shell shebang
      "E501" # line too long (82 > 79 characters)
      "F403" # `from module import *` used; unable to detect undefined names
      "F405" # name may be undefined, or defined from star imports: module
    ];
  } (builtins.readFile ./krisp-patcher.py);

  # The bin name must be something other than `discord` because `betterdiscordctl` will kill all processes
  # by that name as part of the `uninstall` command
  wrapDiscordBinary = pkgs.writeShellScriptBin "discord-better" ''
    ${pkgs.betterdiscordctl}/bin/betterdiscordctl uninstall
    ${pkgs.betterdiscordctl}/bin/betterdiscordctl install
    ${pkgs.findutils}/bin/find -L $HOME/.config/discord -name 'discord_krisp.node' -exec ${discordPatcherBin}/bin/discord-krisp-patcher {} +
    ${pkgs.discord}/bin/discord "$@"
  '';
in {
  options.programs.discord = {
    enable = lib.mkEnableOption "Whether to install Discord, a voice and text chat platform.";
    wrapDiscord = lib.mkEnableOption "Wrap the Discord binary, re-installing BetterDiscord and patching the Krisp module on start-up.";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [discordPatcherBin]
      ++ (
        if cfg.wrapDiscord
        then [wrapDiscordBinary]
        else [pkgs.discord]
      );
  };
}
