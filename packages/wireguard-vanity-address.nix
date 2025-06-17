{
  lib,
  fetchFromGitHub,
  rustPlatform,
  optimiseForNativeCpu ? true,
}:
rustPlatform.buildRustPackage {
  pname = "wireguard-vanity-address";
  version = "0.4.1-alpha.0";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "wireguard-vanity-address";
    rev = "1e9c45d17772d34d38f2dfee2194d6993da57508";
    hash = "sha256-AIa2qoqTTe73ye1ZgJsvs5aUa78Xc6db5i7fPgjRuyU=";
  };

  cargoHash = "sha256-+7OMjIVIXtT/cR3I33C0CmeX7QHAZDmRrSbqH16LDzA=";

  # Make the compiled binary even faster - from my testing, this speeds it up by about 25%
  # This breaks builds that are run on systems other than the one they were compiled for
  RUSTFLAGS = lib.optionalString optimiseForNativeCpu "-C target-cpu=native";

  meta = with lib; {
    description = "Find Wireguard VPN keypairs with a specific readable string";
    homepage = "https://github.com/zedseven/wireguard-vanity-address";
    license = licenses.mit;
    maintainers = with maintainers; [zedseven];
    mainProgram = "wireguard-vanity-address";
  };
}
