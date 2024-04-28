{ lib, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = lib.mkForce "DejaVu Sans 16";
  };
}
