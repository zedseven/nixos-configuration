{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  python3,
}:
stdenv.mkDerivation {
  name = "pyroveil";

  src = fetchFromGitHub {
    owner = "HansKristian-Work";
    repo = "pyroveil";
    rev = "00a602f1d485546b87975f2c013aa6ff12126898";
    hash = "sha256-I4RqZj5M2W5XkgzHNvE+orzRtUBH08poPbfOcnEB+9M=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-G Ninja"
  ];

  # Required because the CMake install prefix isn't used properly for the library path in this file
  postInstall = ''
    sed -ri -e 's!"library_path": ".*?"!"library_path": "'"$out/lib/libVkLayer_pyroveil_64.so"'"!g' $out/share/vulkan/implicit_layer.d/VkLayer_pyroveil_64.json
  '';

  meta = {
    homepage = "https://github.com/HansKristian-Work/pyroveil";
    description = "Vulkan layer library to replace shaders or roundtrip them to workaround driver bugs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.unix;
  };
}
