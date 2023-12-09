# My main PC.
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
    ../../modules/desktop/games.nix
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
    hostName = "duradeus";
    hostId = "c4f086eb";
    wireless = {
      enable = true;
      inherit (private) networks;
    };
  };

  home-manager.users.zacc.programs.autorandr.profiles = {
    "home" = {
      # The easiest way to obtain the fingerprints is to run `autorandr --fingerprint`
      fingerprint = {
        "DP-0" = "00ffffffffffff001e6dfa761ae10400081c0104a55022789eca95a6554ea1260f5054256b807140818081c0a9c0b300d1c08100d1cfcd4600a0a0381f4030203a001e4e3100001a003a801871382d40582c4500132a2100001e000000fd00384b1e5a18000a202020202020000000fc004c4720554c545241574944450a0126020314712309060747100403011f1312830100008c0ad08a20e02d10103e96001e4e31000018295900a0a038274030203a001e4e3100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae";
        "HDMI-0" = "00ffffffffffff004c2d5c0c4b484d302a190103803c22782a5295a556549d250e505423080081c0810081809500a9c0b30001010101023a801871382d40582c450056502100001e011d007251d01e206e28550056502100001e000000fd00323c1e5111000a202020202020000000fc00533237453539300a202020202001af02031af14690041f130312230907078301000066030c00100080011d00bc52d01e20b828554056502100001e8c0ad090204031200c4055005650210000188c0ad08a20e02d10103e9600565021000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061";
      };
      config = {
        "DP-0" = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "2560x1080";
          rate = "74.99";
          dpi = 96;
        };
        "HDMI-0" = {
          enable = true;
          position = "2560x0";
          mode = "1920x1080";
          rate = "60.00";
          dpi = 96;
        };
      };
    };
  };

  hardware.pulseaudio.extraConfig = let
    defaultSink = "alsa_output.usb-Sony_Sony_USB_DAC_Amplifier-00.analog-stereo";
    defaultSource = "alsa_input.pci-0000_0c_00.4.analog-stereo";
  in ''
    .ifexists ${defaultSink}
      set-default-sink ${defaultSink}
      set-sink-volume @DEFAULT_SINK@ 50%
    .endif

    # The extraneous toggles here are because, for some reason, `set-source-mute ... 0` does not unmute
    # the device until it's been toggled
    .ifexists ${defaultSource}
      set-default-source ${defaultSource}
      set-source-mute @DEFAULT_SOURCE@ toggle
      set-source-mute @DEFAULT_SOURCE@ toggle
      set-source-mute @DEFAULT_SOURCE@ 0
    .endif
  '';

  system.stateVersion = "23.05"; # Don't touch this, ever
}
