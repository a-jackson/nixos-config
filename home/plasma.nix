{ ... }:
{
  imports = [
    ./common
    ./common/desktop.nix
    ./common/vscode.nix
    ./common/firefox.nix
    ./common/syncthing.nix
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      icon-theme = "breeze-dark";
    };
  };
}
