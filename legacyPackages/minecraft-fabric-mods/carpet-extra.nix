{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "carpet-extra";
  version = "1.4.148";

  src = fetchurl {
    url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/8gEVsK18/carpet-extra-1.21-1.4.148.jar";
    hash = "sha256-2EJfekuE+8hX30hhhD/1EfvxwcRFL+m7HrRuBFjY2Ps=";
  };

  buildCommand = ''
    install -Dm644 $src $out/mods/${finalAttrs.pname}.jar
  '';

  dontUnpack = true;

  meta = {
    homepage = "https://modrinth.com/mod/carpet-extra";
    description = "An extension adding extra features to Carpet";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [zedseven];
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [binaryBytecode];
  };
})
