{ lib, ... }:
{
  imports = [
    ./hyprland
    ./common
    ./common/desktop.nix
    ./common/vscode.nix
    ./common/firefox.nix
    ../stylix
  ];
  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
    "HDMI-A-1,1920x1080,1920x0,1"
    "DP-1,1920x1080,0x0,1"
  ];
}
