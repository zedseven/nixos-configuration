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
    home.pointerCursor.size = 64;

    xresources.properties = {
      "Xft.dpi" = 192;
    };
  };
}
