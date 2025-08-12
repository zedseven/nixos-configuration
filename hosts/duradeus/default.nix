# My main PC.
{
  config,
  pkgs,
  inputs,
  userInfo,
  ...
}: let
  networkInterfaceWirelessName = "wlp5s0";
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  # Impermanence
  environment.persistence.${config.custom.darlings.persist.mirrorRoot} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/mullvad-vpn"
      "/etc/ssh"
      "/root/.cache/restic"
      "/var/lib/alsa"
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/nixos"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  custom = {
    user.type = "full";
    global.configurationPath = "/persist/etc/nixos";
    darlings.persist.ageIdentityPaths.enable = true;

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = [
        "/home"
        "/persist"
      ];
      extraExcludeEntries = [
        "/home/${userInfo.username}/torrents/artifacts/"
        "/home/${userInfo.username}/git/nixpkgs"
      ];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 00:00:00";
      setEnvironmentVariables = true;
    };

    desktop = {
      enable = true;

      displays = {
        fingerprints = {
          "DP-0" = "00ffffffffffff004c2d5672473245300b220104b54628783b4ed5ae4e45aa270e505421080081c0810081809500a9c0b3000101010108e80030f2705a80b0588a00b9882100001e000000fd0c44f0ffffee010a202020202020000000fc004f6479737365792047380a2020000000ff0048434e583330313035300a2020026b020334f048615f101f3f0403762309070783010000e305c0006d1a0000020f44f000048b065a0ae60605018b5a00e5018b849079565e00a0a0a0295030203500b9882100001a6fc200a0a0a0555030203500b9882100001a023a801871382d40582c4500b9882100001e000000000000000000000000000000000000000000ec70127900000301641fa00384ff0e2f02f7801f006f085900020004000fd00184ff0e2f02af8057006f08590007800900af940104ff093f017f801f009f053a000200040033e900047f0717016b801f003704320002000400037400047f07170157802b0037042c0003800400000000000000000000000000000000000000bf90";
          "DP-4" = "00ffffffffffff004c2d5672473245300b220104b54628783b4ed5ae4e45aa270e505421080081c0810081809500a9c0b3000101010108e80030f2705a80b0588a00b9882100001e000000fd0c44f0ffffee010a202020202020000000fc004f6479737365792047380a2020000000ff0048434e583330313533310a20200267020334f048615f101f3f0403762309070783010000e305c0006d1a0000020f44f000048b065a0ae60605018b5a00e5018b849079565e00a0a0a0295030203500b9882100001a6fc200a0a0a0555030203500b9882100001a023a801871382d40582c4500b9882100001e000000000000000000000000000000000000000000ec70127900000301641fa00384ff0e2f02f7801f006f085900020004000fd00184ff0e2f02af8057006f08590007800900af940104ff093f017f801f009f053a000200040033e900047f0717016b801f003704320002000400037400047f07170157802b0037042c0003800400000000000000000000000000000000000000bf90";
        };

        config = {
          "DP-4" = {
            enable = true;
            primary = true;
            positionX = 0;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 240;
            dpi = 144;
            adaptiveSync = true;
          };
          "DP-0" = {
            enable = true;
            positionX = 3840;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 120; # The monitor supports 240 Hz, but it seems my GPU can't handle 2x 4K @ 240 Hz displays - even though my previous, older card, could handle it just fine...
            dpi = 144;
            adaptiveSync = true;
          };
        };
      };

      suckless.slstatus.arguments = [
        {
          function = "run_command";
          displayFormat = "Audio: %3s"; # Includes the percent sign in its width
          functionArgument = "${pkgs.bash}/bin/bash -c \\\"${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ | ${pkgs.gnugrep}/bin/grep -Po '[0-9]+%' | ${pkgs.coreutils}/bin/head -n1\\\"";
        }
        {
          function = "cpu_perc";
          displayFormat = "CPU: %2s%%";
          functionArgument = "";
        }
        {
          function = "temp";
          displayFormat = "Temp: %2s°C";
          functionArgument = "/sys/class/hwmon/hwmon3/temp1_input";
        }
        {
          function = "ram_perc";
          displayFormat = "RAM: %2s%%";
          functionArgument = "";
        }
        {
          function = "wifi_essid";
          displayFormat = "Wi-Fi: %s";
          functionArgument = networkInterfaceWirelessName;
        }
        {
          function = "datetime";
          displayFormat = "%s";
          functionArgument = "%F %T";
        }
      ];

      displayDriver = "nvidia";
      is4k = true;
      android.enable = true;
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      bluetooth.enable = true;
      blender.enable = true;
      calibre.enable = true;
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games = {
        steam = {
          enable = true;
          wrapSteam = true;
        };
        minecraft.enable = true;
        ndsplus.enable = true;
      };
      printing = {
        enable = true;
        drivers = ["hp"];
      };
      stenography.enable = true;
    };

    symlinks = {
      # `agenix` Values
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;

      # Private Flakes
      "/etc/website-ztdp".source = "/home/${userInfo.username}/git/website-ztdp";
    };

    grub = {
      enable = true;
      efi.enable = true;
    };

    wireguard.enable = true;
    zfs.enable = true;
    qmk.enable = true;
  };

  networking = {
    hostId = "c4f086eb";
    supplicant.${networkInterfaceWirelessName}.configFile.path =
      config.age.secrets."wpa_supplicant.conf".path;
    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled.enable = true;
    };
  };

  hardware.printers.ensurePrinters = [
    {
      name = "HP_DeskJet_3630_series_CF2922";
      description = "HP DeskJet 3630 series";
      location = "Home";
      deviceUri = "dnssd://HP%20DeskJet%203630%20series%20%5BCF2922%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-e4e749cf2922";
      model = "HP/hp-deskjet_3630_series.ppd.gz"; # From `lpinfo -m`, also inside `hplip`
    }
  ];

  # To allow cross-compilation for other architectures
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  system.stateVersion = "23.05"; # Don't touch this, ever
}
