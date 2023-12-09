# An HP Spectre x360 Laptop - 5FP19UA.
let
  private = import ../../private;
in {
  imports = [
    <home-manager/nixos>
    ./hardware-configuration.nix
    ../../modules/global.nix
    ../../modules/physical.nix
    ../../modules/desktop
    ../../modules/desktop/nvidia.nix
    ../../modules/desktop/4k.nix
    ../../modules/darlings.nix
    ../../modules/zfs.nix
    ../../zacc.nix
  ];

  environment = {
    etc = {
      "nixos".source = "/home/zacc/nix";
      "mullvad-vpn".source = "/persist/etc/mullvad-vpn";
    };
  };

  networking = {
    hostName = "wraith";
    hostId = "eff5369a";
    wireless = {
      enable = true;
      inherit (private) networks;
    };
  };

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
      # The easiest way to obtain the fingerprints is to run `autorandr --fingerprint`
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

  system.stateVersion = "23.05"; # Don't touch this, ever
}
