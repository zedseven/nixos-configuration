# An HP Spectre x360 Laptop - 5FP19UA.
{
  config,
  pkgs,
  inputs,
  userInfo,
  ...
}: {
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
          "eDP-1" = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
        };

        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            positionX = 0;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 60;
            dpi = 192;
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
          function = "battery_perc";
          displayFormat = "Battery: %3s%%";
          functionArgument = "BAT0";
        }
        {
          function = "wifi_essid";
          displayFormat = "Wi-Fi: %s";
          functionArgument = "wlp0s20f3";
        }
        {
          function = "datetime";
          displayFormat = "%s";
          functionArgument = "%F %T";
        }
      ];

      displayDriver = "nvidia";
      is4k = true;
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games.ndsplus.enable = true;
      printing = {
        enable = true;
        drivers = ["hp"];
      };
    };

    symlinks = {
      # `agenix` Values
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;
    };

    grub = {
      enable = true;
      efi.enable = true;
    };

    wireguard.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "eff5369a";
    supplicant."WLAN".configFile.path = config.age.secrets."wpa_supplicant.conf".path;
    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled.enable = true;
    };
  };

  hardware = {
    nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:59@0:0:0";
    };

    printers.ensurePrinters = [
      {
        name = "HP_DeskJet_3630_series_CF2922";
        description = "HP DeskJet 3630 series";
        location = "Home";
        deviceUri = "dnssd://HP%20DeskJet%203630%20series%20%5BCF2922%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-e4e749cf2922";
        model = "HP/hp-deskjet_3630_series.ppd.gz"; # From `lpinfo -m`, also inside `hplip`
      }
    ];
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
