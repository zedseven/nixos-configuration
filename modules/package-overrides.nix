{
  lib,
  system,
  ...
}: {
  nixpkgs.overlays = lib.optionals (system == "aarch64-linux") [
    (_: super: {
      fish = super.fish.overrideAttrs (
        oldAttrs: {
          postPatch =
            oldAttrs.postPatch
            + ''
              # This test always fails when building for `aarch64-linux`
              rm tests/pexpects/torn_escapes.py
            '';
        }
      );
    })
  ];
}
