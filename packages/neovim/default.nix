# My personal `neovim` configuration.
{
  inputs,
  pkgs,
  lib,
  stdenvNoCC,
  purefmt,
}:
(
  let
    configName = "main";
  in
    inputs.tolerable.makeNeovimConfig configName {
      inherit pkgs;
      src = stdenvNoCC.mkDerivation {
        name = configName;
        src = lib.fileset.toSource {
          root = ./.;
          fileset = ./. + "/${configName}";
        };

        patches = [./uses-nix.patch];

        installPhase = ''
          mkdir -p $out
          cp -r * $out/ # Copy patched files to output
        '';
      };
      config = {
        plugins = with pkgs.vimPlugins; [
          bufferline-nvim
          catppuccin-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp_luasnip
          conform-nvim
          fidget-nvim
          friendly-snippets
          gitsigns-nvim
          hardtime-nvim
          luasnip
          nvim-cmp
          nvim-lspconfig
          nvim-spider
          nvim-tree-lua
          nvim-treesitter.withAllGrammars
          rustaceanvim
          telescope-nvim
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
          deadnix
          git
          lua-language-server
          nil
          purefmt
          # `rustfmt` and `rust-analyzer` come from the `direnv` environment of each project
          statix
          stylua
          taplo
        ]
      ))
    ];
})
