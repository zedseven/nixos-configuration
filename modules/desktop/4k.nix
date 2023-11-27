{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver = {
    dpi = 192;
  };

  home-manager.users.zacc = {
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 64;
      x11.enable = true;
    };

    xresources.properties = {
      "Xft.dpi" = 192;
    };
  };
}
