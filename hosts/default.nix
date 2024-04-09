{hostname, ...}: {
  imports = [
    ./stock-profiles.nix
    ./${hostname}
  ];

  networking.hostName = hostname;
}
