{
  config,
  lib,
  userInfo,
  ...
}: let
  cfg = config.custom.desktop.is4k;
in {
  options.custom.desktop.is4k = with lib; mkEnableOption "4K display customisations";

  config = lib.mkIf cfg {
    services.xserver.dpi = 144;

    home-manager.users.${userInfo.username} = {
      home.pointerCursor.size = 48;

      xresources.properties = {
        "Xft.dpi" = 144;
      };
    };
  };
}
