# Sourced primarily from:
# https://github.com/nix-community/disko/blob/f67ba6552845ea5d7f596a24d57c33a8a9dc8de9/example/hybrid.nix
# https://github.com/nix-community/disko/blob/f67ba6552845ea5d7f596a24d57c33a8a9dc8de9/example/zfs.nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "<disk-name>"; # Set this before use
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # For GRUB MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              end = "-4G"; # Swap size
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
            swap = {
              size = "100%"; # Fills the remaining space at the end, which should be `swapSizeGigabytes`
              type = "8200";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
        };
        postCreateHook = "zfs snapshot rpool/local/root@blank"; # For `darlings`

        datasets = {
          "local/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };
          "local/nix" = {
            type = "zfs_fs";
            options = {
              dedup = "on";
              mountpoint = "legacy";
            };
            mountpoint = "/nix";
          };
          "safe/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
          "safe/persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };
        };
      };
    };
  };
}
