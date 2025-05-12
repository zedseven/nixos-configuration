{
  lib,
  hostname,
  ...
}: {
  imports = [
    ./stock-profiles.nix
    ./${hostname}
  ];

  networking.hostName = lib.mkDefault hostname;
}
