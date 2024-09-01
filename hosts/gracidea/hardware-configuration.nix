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
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
      ];
      kernelModules = [];
    };

    loader.grub.device = "/dev/disk/by-id/scsi-3600926ab65fe44a8a4de80da89ca601b";

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
      device = "/dev/disk/by-uuid/CA0D-E363";
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

  swapDevices = [{device = "/dev/disk/by-uuid/f2e46cff-3530-4a68-8a43-283eff1411a7";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
}
