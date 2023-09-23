{ pkgs, ... }:
{
  imports = [
    ./packages/gnome.nix
    ./packages/coding.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  users.users.andrew = {
    packages = with pkgs; [
      firefox
    ];
  };
}
