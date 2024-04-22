{ lib, ... }:
{
  programs.rofi = {
    enable = true;
    font = lib.mkForce "DejaVu Sans 16";
  };
}
