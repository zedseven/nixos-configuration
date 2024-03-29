{
  lib,
  modulesPath,
  system,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "virtio_pci"
        "virtio_scsi"
        "xhci_pci"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [];
    };

    loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_42413165";

    kernelModules = [];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/185B-C6C8";
      fsType = "vfat";
    };

    "/home" = {
      device = "rpool/safe/home";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/persist" = {
      device = "rpool/safe/persist";
      fsType = "zfs";
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/d1faf4e0-9972-4b16-bfa4-4bb0b201af03";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
}
