fetchFromGitHub: let
  catppuccin-st = fetchFromGitHub {
    owner = "catppuccin";
    repo = "st";
    rev = "37c73559b8ce3da2d7bbcd1538daddbbe45c289d";
    hash = "sha256-r+Dll1Ma3CS7CxwkU3L5gvIRM0BJTHhVeTa5iRsigo0=";
  };
in {
  st.catppuccin = {
    frappe = builtins.readFile "${catppuccin-st}/themes/frappe.h";
    latte = builtins.readFile "${catppuccin-st}/themes/latte.h";
    macchiato = builtins.readFile "${catppuccin-st}/themes/macchiato.h";
    mocha = builtins.readFile "${catppuccin-st}/themes/mocha.h";
  };
}
