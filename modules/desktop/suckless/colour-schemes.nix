fetchFromGitHub: let
  catppuccin-st = fetchFromGitHub {
    owner = "catppuccin";
    repo = "st";
    rev = "37c73559b8ce3da2d7bbcd1538daddbbe45c289d";
    hash = "sha256-r+Dll1Ma3CS7CxwkU3L5gvIRM0BJTHhVeTa5iRsigo0=";
  };
in {
  # https://github.com/catppuccin/catppuccin?tab=readme-ov-file#-palette
  dwm.catppuccin = {
    frappe = {
      grey1 = "#303446"; # Base
      grey2 = "#414559"; # Surface0
      grey3 = "#626880"; # Surface2
      grey4 = "#c6d0f5"; # Text
      active = "#85c1dc"; # Sapphire
    };
    latte = {
      grey1 = "#eff1f5"; # Base
      grey2 = "#ccd0da"; # Surface0
      grey3 = "#acb0be"; # Surface2
      grey4 = "#4c4f69"; # Text
      active = "#209fb5"; # Sapphire
    };
    macchiato = {
      grey1 = "#24273a"; # Base
      grey2 = "#363a4f"; # Surface0
      grey3 = "#5b6078"; # Surface2
      grey4 = "#cad3f5"; # Text
      active = "#7dc4e4"; # Sapphire
    };
    mocha = {
      grey1 = "#1e1e2e"; # Base
      grey2 = "#313244"; # Surface0
      grey3 = "#585b70"; # Surface2
      grey4 = "#cdd6f4"; # Text
      active = "#74c7ec"; # Sapphire
    };
  };
  st.catppuccin = {
    frappe = builtins.readFile "${catppuccin-st}/themes/frappe.h";
    latte = builtins.readFile "${catppuccin-st}/themes/latte.h";
    macchiato = builtins.readFile "${catppuccin-st}/themes/macchiato.h";
    mocha = builtins.readFile "${catppuccin-st}/themes/mocha.h";
  };
}
