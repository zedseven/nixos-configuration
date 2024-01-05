{
  pkgs,
  lib,
  inputs,
  system,
  ...
}: let
  programsDbRedirectionPath = "/etc/programs.sqlite";
in {
  imports = [
    inputs.private.nixosModules.default
    ./symlinks.nix
  ];

  system = let
    self = inputs.self;
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
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
  nix = {
    channel.enable = false;
    # Only `nixpkgs` is pinned because none of the other inputs are used outside of the flake
    nixPath = ["nixpkgs=flake:nixpkgs"];
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.utf8";

  security.sudo.extraConfig = ''
    Defaults lecture="never"
    Defaults timestamp_timeout=15
  '';

  environment = {
    systemPackages = with pkgs; [
      (inputs.agenix.packages.${system}.default.override {ageBin = "${rage}/bin/rage";})
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
      X11Forwarding = true;
    };
  };
}
