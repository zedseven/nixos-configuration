{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.supportedFilesystems = ["zfs"];

  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
}
