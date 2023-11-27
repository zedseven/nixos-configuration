{lib, ...}: {
  # Wipe the root directory on boot
  # NixOS will rebuild it every time, giving the system a "new computer feel" on every boot
  # This also tests the system's ability to build from scratch
  # https://grahamc.com/blog/erase-your-darlings/
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';
}
