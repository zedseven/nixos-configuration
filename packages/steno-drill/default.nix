{
  lib,
  fetchFromGitHub,
  rustPlatform,
  sqlite,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "steno-drill";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tangybbq";
    repo = "steno-drill";
    rev = "73ec3f55ca92692390b41d2941c28d1cb92ec326";
    hash = "sha256-sflWEypLv9DBnj+MqDgoxiLHdSWLN9Zn+wkqM+9+Wm0=";
  };

  cargoHash = "sha256-1TvzxupCu+M5AoJvtdAHGY8/ULFJHJGmxANha4kELeo=";

  patches = [./newer-rust-versions.patch];

  buildInputs = [sqlite];

  meta = {
    description = "Steno drilling utility";
    homepage = "https://github.com/tangybbq/steno-drill";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "steno-drill";
  };
}
