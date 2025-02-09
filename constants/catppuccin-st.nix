fetchFromGitHub: let
  source = fetchFromGitHub {
    owner = "catppuccin";
    repo = "st";
    rev = "37c73559b8ce3da2d7bbcd1538daddbbe45c289d";
    hash = "sha256-r+Dll1Ma3CS7CxwkU3L5gvIRM0BJTHhVeTa5iRsigo0=";
  };
in {
  frappe = builtins.readFile "${source}/themes/frappe.h";
  latte = builtins.readFile "${source}/themes/latte.h";
  macchiato = builtins.readFile "${source}/themes/macchiato.h";
  mocha = builtins.readFile "${source}/themes/mocha.h";
}
