{
  fetchFromGitHub,
  wireguard-vanity-address,
  ...
}:
wireguard-vanity-address.overrideAttrs (
  oldAttrs: let
    src = fetchFromGitHub {
      owner = "warner";
      repo = "wireguard-vanity-address";
      rev = "803e4c5606f16cc81de44b968ef4cd11acc1a8c4"; # 12-count-scalars branch, Significantly faster
      hash = "sha256-n9iLktJt8YoLtABK0xmzsA4RL7cZoz5umol85KS0u5w=";
    };
  in {
    inherit src;
    doCheck = false;
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-xbbHrQ5Lsr0kNWdUrI6hP9Gf1b8rYkv+P3COaQM80wo=";
    };

    # Make the compiled binary even faster
    RUSTFLAGS = "-C target-cpu=native";
    patches = oldAttrs.patches ++ [./faster.patch];
  }
)
