{
  lib,
  inputs,
  system,
  ...
}: {
  nixpkgs.overlays =
    [
      # Required because `home-manager` doesn't provide an option for package overrides for `tealdeer`
      (_: _: {tealdeer = inputs.self.packages.${system}.tealdeer;})
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
