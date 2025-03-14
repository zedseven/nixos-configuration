{
  config,
  lib,
  modulesPath,
  system,
  ...
}: let
  swapDevice = "/dev/disk/by-uuid/3433d9c0-ebca-4967-88d9-5669d188728c";
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [];

      luks.devices = {
        crypt-key = {
          device = "/dev/disk/by-uuid/5a87fc40-0e29-4575-b229-9c6186bea0d1";
          preLVM = true;
        };

        crypt-swap = {
          device = "/dev/disk/by-uuid/76e7e000-376d-4710-a05f-5e1e0df787b2";
          keyFile = "/dev/mapper/crypt-key";
          preLVM = true;
        };

        crypt-root = {
          device = "/dev/disk/by-uuid/07e0d6c0-3452-4151-878b-55fa71078654";
          keyFile = "/dev/mapper/crypt-key";
          preLVM = true;
        };
      };
    };

    loader.grub.enableCryptodisk = true;
    supportedFilesystems = ["zfs"];

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    resumeDevice = swapDevice;
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=16G"
        "mode=755"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8844-033D";
      fsType = "vfat";
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/safe/home";
      fsType = "zfs";
    };

    "/persist" = {
      device = "rpool/safe/persist";
      fsType = "zfs";
      neededForBoot = true; # Required because this is where the secret decryption key is stored
    };
  };

  swapDevices = [{device = swapDevice;}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
