{
  services.xserver.dpi = 192;

  home-manager.users.${userInfo.username} = {
    home.pointerCursor.size = 64;

    xresources.properties = {
      "Xft.dpi" = 192;
    };
  };
}
