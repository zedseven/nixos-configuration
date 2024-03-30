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
in {
  imports = [
    inputs.private.nixosModules.default
    ./symlinks.nix
  ];

  options.custom.global = with lib; {
    configurationPath = mkOption {
      description = mdDoc "The path to where the NixOS configuration is stored on the machine.";
      type = types.path;
      default = "/etc/nixos";
    };
  };

  config = {
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
      permittedInsecurePackages = ["electron-25.9.0"];
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
        dates = "daily";
        options = "--delete-older-than 14d";
      };
      settings.nix-path = nixPath; # https://github.com/NixOS/nix/issues/8890#issuecomment-1703988345
    };

    # Disable documentation on servers
    documentation.enable = !isServer;

    # Prevent users and groups from being modified at runtime
    users.mutableUsers = false;

    # Set your time zone.
    time.timeZone = "America/Toronto";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_CA.utf8";

    security.sudo.extraConfig = ''
      Defaults lecture="never"
      Defaults timestamp_timeout=15
    '';

    environment = {
      variables.FLAKE = cfg.configurationPath; # Required by `nh`, allowing rebuilds without providing the path every time
      systemPackages = with pkgs; [
        (inputs.agenix.packages.${system}.default.override {ageBin = "${rage}/bin/rage";})
        inputs.nh.packages.${system}.default
        killall
        lshw
        lsof
        pciutils
        rage
        unzip
        wget
      ];
      shells = with pkgs; [fish];
    };

    custom.symlinks = {
      # https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/
      ${programsDbRedirectionPath}.source = "${inputs.programs-db.packages.${system}.programs-sqlite}";
    };

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
  };
}
