{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fabric-api";
  version = "0.114.0+1.21.1";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/biIRIp2X/fabric-api-0.114.0%2B1.21.1.jar";
    hash = "sha256-4wPOj0vdo72Io/Wx39Vo8GHAjxCbOh/Q96CiDFd6Gp8=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/fabric-api";
    description = "Essential hooks for modding with Fabric";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
