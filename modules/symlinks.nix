{
  config,
  lib,
  ...
}: let
  cfg = config.custom.symlinks;
in {
  # This is mostly based on the implementation of `environment.etc` in the main NixOS source
  options.custom.symlinks = with lib;
    mkOption {
      description = "The symlinks to create.";
      type = types.attrsOf (
        types.submodule (
          {name, ...}: {
            options = {
              target = mkOption {
                description = "Path of the symlink. Defaults to the name of the module.";
                type = types.path;
                default = name;
              };

              source = mkOption {
                description = "Path of the symlink source.";
                type = types.path;
              };

              override = mkOption {
                description = "If a file or directory already exists at the destination, it will be removed.";
                type = types.bool;
                default = true;
              };

              onlyOnBoot = mkOption {
                description = "Only create the symlink during boot. Only required if touching the symlink could break a running system.";
                type = types.bool;
                default = false;
              };
            };
          }
        )
      );
      default = {};
    };

  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
  config = {
    systemd.tmpfiles.rules =
      lib.attrsets.mapAttrsToList
      (
        _: link: let
          type = lib.concatStrings [
            "L"
            (lib.optionalString link.override "+")
            (lib.optionalString link.onlyOnBoot "!")
          ];
          escapeSpaces = text: lib.strings.escapeC [" "] text;
          escapedTarget = escapeSpaces (builtins.toString link.target);
          escapedSource = escapeSpaces (builtins.toString link.source);
        in "${type} ${escapedTarget} - - - - ${escapedSource}"
      )
      cfg;
  };
}
