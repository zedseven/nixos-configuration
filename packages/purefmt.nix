{
  writeShellScriptBin,
  alejandra,
  nixfmt-rfc-style,
  ...
}:
writeShellScriptBin "purefmt" ''
  # Exit early if any command is unsuccessful
  set -o errexit

  TARGET="$1"

  # For purity - https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md#initial-standard-nix-format
  ${nixfmt-rfc-style}/bin/nixfmt "$TARGET"

  # For the style of `alejandra`
  ${alejandra}/bin/alejandra --quiet "$TARGET"
''
