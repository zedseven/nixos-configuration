{
  writeShellScriptBin,
  alejandra,
  nixfmt-tree, # Uses `nixfmt-rfc-style` internally
  ...
}:
writeShellScriptBin "purefmt" ''
  # Exit early if any command is unsuccessful
  set -o errexit

  # For purity - https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md#initial-standard-nix-format
  ${nixfmt-tree}/bin/treefmt "$@"

  # For the style of `alejandra`
  ${alejandra}/bin/alejandra --quiet "$@"
''
