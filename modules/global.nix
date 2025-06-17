{
  config,
  pkgs,
  lib,
  inputs,
  system,
  isServer,
  ...
}: let
  cfg = config.custom.global;
  programsDbRedirectionPath = "/etc/programs.sqlite";
  defaultConfigurationPath = "/etc/nixos";
in {
  imports = [
    inputs.private.nixosModules.default
    ./symlinks.nix
  ];

  options.custom.global = with lib; {
    configurationPath = mkOption {
      description = mdDoc "The path to where the NixOS configuration is stored on the machine.";
      type = types.nullOr types.path;
      default =
        if isServer
        then null
        else defaultConfigurationPath;
    };
  };

  config = lib.mkMerge [
    {
      system = let
        inherit (inputs) self;
      in {
        configurationRevision = self.rev or self.dirtyRev;
        # Sets the label that shows on the GRUB boot menu
        nixos.tags = let
          cut = revision: builtins.substring 0 8 revision;
          dirtySuffix = "-dirty";
        in [
          (
            if (self.rev or null) != null
            then (cut self.rev)
            else ((cut self.dirtyRev) + dirtySuffix)
          )
        ];
      };

      nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [];
      };
      nix = rec {
        channel.enable = false;
        # Only `nixpkgs` is pinned because none of the other inputs are used outside of the flake
        nixPath = ["nixpkgs=flake:nixpkgs"];
        registry.nixpkgs.flake = inputs.nixpkgs;
        settings = {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = ["@wheel"]; # Trust any user with `sudo` privileges to update the Nix configuration
        };
        gc = {
          automatic = true;
          dates = "monthly";
          options = "--delete-older-than 31d";
        };
        settings.nix-path = nixPath; # https://github.com/NixOS/nix/issues/8890#issuecomment-1703988345
      };

      # Prevent users and groups from being modified at runtime
      users = {
        mutableUsers = false;
        users.root.hashedPassword = inputs.private.unencryptedValues.users.root.hashedPassword;
      };

      # Set your time zone.
      time.timeZone = "America/Toronto";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_CA.UTF-8";

      security.sudo.extraConfig = ''
        Defaults lecture="never"
        Defaults timestamp_timeout=15
      '';

      environment = {
        systemPackages = with pkgs; [
          inputs.agenix.packages.${system}.default
          inputs.nh.packages.${system}.default
          killall
          lshw
          lsof
          pciutils
          unzip
          wget
        ];
        shells = with pkgs; [fish];
      };

      # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
      custom.symlinks.${programsDbRedirectionPath}.source = "${inputs.programs-db.packages.${system}.programs-sqlite}";

      programs = {
        command-not-found.dbPath = programsDbRedirectionPath;
        fish.enable = true;
        neovim = {
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };
      };

      # Enable OpenSSH to have host keys generated, but don't open the firewall unless it's actually needed
      services.openssh = {
        enable = true;
        openFirewall = lib.mkDefault false;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    }
    (lib.mkIf (cfg.configurationPath != null) {
      # Required by `nh`, allowing rebuilds without providing the path every time
      environment.sessionVariables.NH_FLAKE = cfg.configurationPath;
    })
    (lib.mkIf (cfg.configurationPath != null && cfg.configurationPath != defaultConfigurationPath) {
      # Set up a symlink to make the non-standard configuration path accessible from the default location
      custom.symlinks.${defaultConfigurationPath}.source = cfg.configurationPath;
    })
  ];
}
