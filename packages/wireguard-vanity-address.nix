{
  lib,
  fetchFromGitHub,
  wireguard-vanity-address,
  optimiseForNativeCpu ? true,
  ...
}:
wireguard-vanity-address.overrideAttrs (
  oldAttrs: let
    src = fetchFromGitHub {
      owner = "zedseven";
      repo = "wireguard-vanity-address";
      rev = "5a5fcf4f8fd25c83c1db5e6437b54eb89b342318";
      hash = "sha256-HRJUdZ+C6TcQACv0Bv1hvq7u61D3qbNFcN16SgFHCyE=";
    };
  in {
    inherit src;
    doCheck = false;
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-xbbHrQ5Lsr0kNWdUrI6hP9Gf1b8rYkv+P3COaQM80wo=";
    };

    # Make the compiled binary even faster - from my testing, this speeds it up by about 25%
    # This breaks builds that are run on systems other than the one they were compiled for
    RUSTFLAGS = lib.optionalString optimiseForNativeCpu "-C target-cpu=native";
  }
)
