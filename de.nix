{ pkgs, ... }:
{
  imports = [
    ./modules/gnome.nix
    ./modules/flatpak.nix
  ];
}
