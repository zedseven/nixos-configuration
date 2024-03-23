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

  # For purity
  ${nixfmt-rfc-style}/bin/nixfmt "$TARGET"

  # For the style of `alejandra`
  ${alejandra}/bin/alejandra --quiet "$TARGET"
''
