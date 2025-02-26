{ ... }:
{
  imports = [
    ./common
    ./common/desktop.nix
    ./common/firefox.nix
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      icon-theme = "breeze-dark";
    };
  };
}
