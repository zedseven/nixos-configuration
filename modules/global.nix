{
  self,
  pkgs,
  lib,
  nixpkgs,
  agenix,
  programs-db,
  private,
  system,
  ...
}: let
  programsDbRedirectionPath = "/etc/programs.sqlite";
in {
  imports = [
    private.nixosModules.default
    ./symlinks.nix
  ];

  system.configurationRevision = self.rev or self.dirtyRev;

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
    registry.nixpkgs.flake = nixpkgs;
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
      (agenix.packages.${system}.default.override {ageBin = "${rage}/bin/rage";})
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
    ${programsDbRedirectionPath}.source = "${programs-db.packages.${system}.programs-sqlite}";
  };

  programs = {
    command-not-found.dbPath = programsDbRedirectionPath;
    fish.enable = true;
    vim.defaultEditor = true;
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
