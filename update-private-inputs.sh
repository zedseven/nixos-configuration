#!/usr/bin/env bash

# Exit early if there are any errors
set -o errexit

# Constants
FLAKE_LOCK_FILE="./flake.lock"

PRIVATE_FLAKE_NAME="private"
PRIVATE_FLAKE_URL="file:///etc/nixos/private"

WEBSITE_FLAKE_NAME="website-ztdp"
WEBSITE_FLAKE_URL="file:///etc/website-ztdp"

# Ensure the script is being run in the same directory as itself
test -f "./$(basename $(realpath "$0"))"

# Update the flake lockfile
nix flake lock --update-input "$PRIVATE_FLAKE_NAME"
nix flake lock --update-input "$WEBSITE_FLAKE_NAME"

# Nix resolves symlinks for flake inputs, which causes problems on systems where the resolved absolute path isn't present
# This sets the path back to the desired one that should always be present across all systems
sd --flags 'ms' '("'"$PRIVATE_FLAKE_NAME"'": \{.*?"locked": \{.*?"url":) ".*?"' '$1 "'"$PRIVATE_FLAKE_URL"'"' "$FLAKE_LOCK_FILE"
sd --flags 'ms' '("'"$WEBSITE_FLAKE_NAME"'": \{.*?"locked": \{.*?"url":) ".*?"' '$1 "'"$WEBSITE_FLAKE_URL"'"' "$FLAKE_LOCK_FILE"
