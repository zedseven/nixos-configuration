{
  config,
  lib,
  modulesPath,
  system,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];

      luks.devices = {
        crypt-key = {
          device = "/dev/disk/by-uuid/b1ddcaa2-cc16-405a-a9d7-e889a789a8f5";
          preLVM = true;
        };

        crypt-swap = {
          device = "/dev/disk/by-uuid/4150e9c1-1e8b-4ee9-853f-7b4a13308803";
          keyFile = "/dev/mapper/crypt-key";
          preLVM = true;
        };

        crypt-root = {
          device = "/dev/disk/by-uuid/1bea5f50-e611-4df8-a125-e2b01e98d3cb";
          keyFile = "/dev/mapper/crypt-key";
          preLVM = true;
        };
      };
    };

    loader.grub.enableCryptodisk = true;
    supportedFilesystems = [
      "zfs"
      "ntfs"
    ];

    kernelModules = ["kvm-amd"];
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
      device = "/dev/disk/by-uuid/EB86-73C4";
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

    # Old Drives
    "/old/windows/f" = {
      device = "/dev/disk/by-uuid/14C8BCDDC8BCBDF4";
      fsType = "ntfs";
      options = [
        "nofail"
        "ro"
      ];
    };

    "/old/windows/g" = {
      device = "/dev/disk/by-uuid/FA16C3F616C3B245";
      fsType = "ntfs";
      options = [
        "nofail"
        "ro"
      ];
    };

    "/old/windows/y" = {
      device = "/dev/disk/by-uuid/804C9CD74C9CC974";
      fsType = "ntfs";
      options = [
        "nofail"
        "ro"
      ];
    };

    "/old/windows/z" = {
      device = "/dev/disk/by-uuid/FEFAC026FABFD95B";
      fsType = "ntfs";
      options = [
        "nofail"
        "ro"
      ];
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/2db9cbb4-6936-4788-8a35-8936c5b8d688";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
