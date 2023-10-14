{ pkgs, ... }:
{
  imports = [
    ./modules/gnome.nix
    ./modules/coding.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  users.users.andrew = {
    packages = with pkgs; [
      firefox-wayland
    ];
  };
}
