{
  self,
  pkgs,
  nixpkgs,
  home-manager,
  ...
}: {
  system.configurationRevision = self.rev or self.dirtyRev;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
  nix = {
    registry = {
      nixpkgs.flake = nixpkgs;
      home-manager.flake = home-manager;
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
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
      killall
      lshw
      lsof
      pciutils
      unzip
      vim
      wget
    ];
    shells = with pkgs; [fish];
  };

  programs.fish.enable = true;
}
