{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.packageOverrides = pkgs: {
    dmenu = pkgs.dmenu.overrideAttrs {
      src = /home/zacc/suckless/dmenu;
    };
    dwm = pkgs.dwm.overrideAttrs {
      src = /home/zacc/suckless/dwm;
    };
    slock = pkgs.slock.overrideAttrs {
      src = /home/zacc/suckless/slock;
    };
    slstatus = pkgs.slstatus.overrideAttrs {
      src = /home/zacc/suckless/slstatus;
    };
    st = pkgs.st.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ [pkgs.harfbuzz];
      src = /home/zacc/suckless/st;
    });
  };
}
