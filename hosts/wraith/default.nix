let
  private = import ../../private;
in
  {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      <home-manager/nixos>
      ./hardware-configuration.nix
      ../../modules/global.nix
      ../../modules/desktop
      ../../modules/desktop/nvidia.nix
      ../../modules/desktop/4k.nix
      ../../modules/darlings.nix
      ../../modules/zfs.nix
      ../../zacc.nix
    ];

    environment = {
      etc."nixos".source = "/home/zacc/nix";
      etc."mullvad-vpn".source = "/persist/etc/mullvad-vpn";
    };

    networking.hostName = "wraith"; # Define your hostname.
    networking.hostId = "eff5369a";

    networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
    networking.wireless.networks = private.networks;

    hardware.nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:59@0:0:0";
    };

    home-manager.users.zacc.programs.autorandr.profiles = {
      "home" = {
        # The easiest way to obtain these values is to run `autorandr --fingerprint`
        fingerprint = {
          "eDP-1" = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
        };
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "3840x2160";
            rate = "60.00";
            dpi = 192;
          };
        };
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  }
