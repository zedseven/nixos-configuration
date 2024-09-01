{
  lib,
  inputs,
  modulesPath,
  system,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  services.qemuGuest = {
    enable = true;
    package = inputs.self.packages.${system}.qemu-guest;
  };

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
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=2G"
        "mode=755"
      ];
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
      neededForBoot = true; # Required because this is where the secret decryption key is stored
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/d1faf4e0-9972-4b16-bfa4-4bb0b201af03";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
}
