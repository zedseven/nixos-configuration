# Copied from `nixpkgs` at revision `8c36d99af2e175f672d4bec31d2e622d09f17472`
{
  lib,
  stdenv,
  fetchurl,
  jre_headless,
  makeWrapper,
  udev,
}:
stdenv.mkDerivation {
  pname = "minecraft-server";
  version = "1.21.1";

  # Find the URLs for new versions at: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/games/minecraft-servers/versions.json
  src = fetchurl {
    url = "https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar";
    hash = "sha256-47xVaT6TzaAYjy5grqKBE/xkfF6FoV+j0bNHNJIxtLs=";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/lib/minecraft/server.jar

    makeWrapper ${lib.getExe jre_headless} $out/bin/minecraft-server \
      --append-flags "-jar $out/lib/minecraft/server.jar nogui" \
      ${lib.optionalString stdenv.isLinux "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [udev]}"}

    runHook postInstall
  '';

  dontUnpack = true;

  meta = with lib; {
    homepage = "https://minecraft.net";
    description = "Minecraft Server";
    license = licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [zedseven];
    platforms = platforms.unix;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
