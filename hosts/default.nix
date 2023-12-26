{hostname, ...}: {
  imports = [./${hostname}];

  networking.hostName = hostname;
}
