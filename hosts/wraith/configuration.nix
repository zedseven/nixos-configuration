let
  private = import ./private;
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

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  }
