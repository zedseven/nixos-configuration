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
  dmenu.catppuccin = {
    # Based on https://github.com/catppuccin/dmenu
    frappe = {
      normalForeground = "#c6d0f5"; # Text
      normalBackground = "#303446"; # Base
      selectedForeground = "#303446"; # Base
      selectedBackground = "#85c1dc"; # Sapphire
      outForeground = "#000000";
      outBackground = "#85c1dc"; # Sapphire
      highlightForeground = "#e78284"; # Red
      highPriorityForeground = "#c6d0f5"; # Text
      highPriorityBackground = "#414559"; # Surface0
    };
    latte = {
      normalForeground = "#4c4f69"; # Text
      normalBackground = "#eff1f5"; # Base
      selectedForeground = "#eff1f5"; # Base
      selectedBackground = "#209fb5"; # Sapphire
      outForeground = "#000000";
      outBackground = "#209fb5"; # Sapphire
      highlightForeground = "#d20f39"; # Red
      highPriorityForeground = "#4c4f69"; # Text
      highPriorityBackground = "#ccd0da"; # Surface0
    };
    macchiato = {
      normalForeground = "#cad3f5"; # Text
      normalBackground = "#24273a"; # Base
      selectedForeground = "#24273a"; # Base
      selectedBackground = "#7dc4e4"; # Sapphire
      outForeground = "#000000";
      outBackground = "#7dc4e4"; # Sapphire
      highlightForeground = "#ed8796"; # Red
      highPriorityForeground = "#cad3f5"; # Text
      highPriorityBackground = "#363a4f"; # Surface0
    };
    mocha = {
      normalForeground = "#cdd6f4"; # Text
      normalBackground = "#1e1e2e"; # Base
      selectedForeground = "#1e1e2e"; # Base
      selectedBackground = "#74c7ec"; # Sapphire
      outForeground = "#000000";
      outBackground = "#74c7ec"; # Sapphire
      highlightForeground = "#f38ba8"; # Red
      highPriorityForeground = "#cdd6f4"; # Text
      highPriorityBackground = "#313244"; # Surface0
    };
  };
  st.catppuccin = {
    frappe = builtins.readFile "${catppuccin-st}/themes/frappe.h";
    latte = builtins.readFile "${catppuccin-st}/themes/latte.h";
    macchiato = builtins.readFile "${catppuccin-st}/themes/macchiato.h";
    mocha = builtins.readFile "${catppuccin-st}/themes/mocha.h";
  };
}
