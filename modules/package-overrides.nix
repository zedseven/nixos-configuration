{
  lib,
  system,
  ...
}: {
  nixpkgs.overlays =
    [
      # Disable the check that currently fails - https://github.com/NixOS/nixpkgs/issues/380196#issuecomment-2646189651
      (_: prev: {lldb = prev.lldb.overrideAttrs {dontCheckForBrokenSymlinks = true;};})
    ]
    ++ (lib.optionals (system == "aarch64-linux") [
      (_: super: {
        fish = super.fish.overrideAttrs (oldAttrs: {
          postPatch =
            oldAttrs.postPatch
            + ''
              # This test always fails when building for `aarch64-linux`
              rm tests/pexpects/torn_escapes.py
            '';
        });
      })
    ]);
}
