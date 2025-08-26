# My personal `neovim` configuration.
{
  inputs,
  pkgs,
  lib,
  purefmt,
}:
(
  let
    configName = "main";
  in
    inputs.tolerable.makeNeovimConfig configName {
      inherit pkgs;
      src = lib.fileset.toSource {
        root = ./.;
        fileset = ./. + "/${configName}";
      };
      config = {
        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          which-key-nvim
        ];
      };
    }
).overrideAttrs
(oldAttrs: {
  generatedWrapperArgs =
    (oldAttrs.generatedWrapperArgs or [])
    ++ [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath (
        with pkgs; [
          git
          nil
          purefmt
          statix
        ]
      ))
    ];
})
