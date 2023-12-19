{ pkgs, lib, config, ... }:
{

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    steam
    protontricks
  ];
}
