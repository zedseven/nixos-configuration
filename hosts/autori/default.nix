# The main server for hosting web services, among other things.
{
  config,
  inputs,
  hostname,
  userInfo,
  system,
  ...
}: let
  radiumWorkingDirectory = "/var/run/radium";
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
      "/etc/ssh"
      "/root/.cache/restic"
      "/var/lib/acme"
      "/var/lib/nixos"
      "/var/log"
      radiumWorkingDirectory
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  custom = {
    user.type = "minimal";
    darlings.persist.ageIdentityPaths.enable = true;

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = [
        "/home"
        "/persist"
      ];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 01:00:00";
    };

    symlinks."${radiumWorkingDirectory}/.env".source = config.age.secrets."radium.env".path;

    grub.enable = true;
    wireguard.enable = true;
    zfs.enable = true;

    lavalink = {
      enable = true;
      password = inputs.private.unencryptedValues.passwords.lavalink;
      plugins = with inputs.self.legacyPackages.${system}.lavalinkPlugins; [
        dunctebot
        lavasrc
        youtube-source
      ];
      extraConfig = {
        lavalink.server.sources.youtube = false; # Because `youtube-source` is used instead
        plugins = {
          youtube = {
            enabled = true;
            allowSearch = true;
            allowDirectVideoIds = true;
            allowDirectPlaylistIds = true;
            clients = [
              "MUSIC"
              "ANDROID_TESTSUITE"
              "WEB"
              "TVHTML5EMBEDDED"
            ];
          };
          lavasrc = {
            providers = [
              "ytsearch:\"%ISRC%\"" # Will be ignored if track does not have an ISRC. See https://en.wikipedia.org/wiki/International_Standard_Recording_Code
              "ytsearch:%QUERY%" # Will be used if track has no ISRC or no track could be found for the ISRC
              #"scsearch:%QUERY%" # you can add multiple other fallback sources here
            ];
            sources = {
              spotify = true; # Enable Spotify source
              applemusic = false; # Enable Apple Music source
            };
            spotify = {
              inherit (inputs.private.unencryptedValues.passwords.spotify) clientId clientSecret;

              countryCode = "CA"; # the country code you want to use for filtering the artists top tracks. See https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
            };
          };
          dunctebot = {
            ttsLanguage = "en-CA"; # language of the TTS engine
            sources = {
              # true = source enabled, false = source disabled
              getyarn = true; # www.getyarn.io
              clypit = true; # www.clyp.it
              tts = true; # speak:Words to speak
              reddit = true; # should be self-explanatory
              ocremix = true; # www.ocremix.org
              tiktok = true; # tiktok.com
              mixcloud = true; # mixcloud.com
            };
          };
        };
      };
    };
  };

  networking = let
    interface = "ens3";
    hetzner = import ../../constants/hetzner.nix;
  in {
    hostId = "0824a9c7";
    firewall.allowedTCPPorts = [
      80
      443
    ];

    # This is required due to a known IPv6 issue with Hetzner
    # https://docs.hetzner.com/cloud/servers/static-configuration/
    # https://docs.hetzner.com/cloud/servers/primary-ips/primary-ip-configuration/
    # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/3
    interfaces.${interface} = {
      ipv6.addresses = [inputs.private.unencryptedValues.serverAddresses.${hostname}.ipv6];
    };
    defaultGateway6 = {
      inherit interface;
      address = hetzner.gatewayAddresses.ipv6;
    };
  };

  services = {
    openssh = {
      openFirewall = true;
      ports = [inputs.private.unencryptedValues.serverPorts.${hostname}.ssh];
    };

    nginx = {
      enable = true;
      virtualHosts."ztdp.ca" = {
        enableACME = true;
        forceSSL = true;
        root = "${inputs.website-ztdp.packages.${system}.default}";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = userInfo.email;
  };

  systemd.services."radium" = {
    enable = true;
    description = "Radium";
    after = [
      "network.target"
      "lavalink.service"
    ];
    wants = ["lavalink.service"];
    serviceConfig = {
      ExecStart = "${inputs.self.packages.${system}.radium}/bin/radium";
      WorkingDirectory = radiumWorkingDirectory;
      Restart = "on-failure";
      RestartSec = "5s";
      User = "radium";
      Group = "radium";
    };
    wantedBy = ["multi-user.target"];
  };

  users = {
    users.radium = {
      isSystemUser = true;
      group = "radium";
    };
    groups.radium = {};
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
