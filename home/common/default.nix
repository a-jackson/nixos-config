{ pkgs, lib, config, ... }:
{
  imports = [
    ./shell.nix
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    documents = "${config.home.homeDirectory}/documents";
    desktop = "${config.home.homeDirectory}/desktop";
    download = "${config.home.homeDirectory}/downloads";
    music = null;
    pictures = null;
    videos = null;
    templates = null;
    publicShare = null;
  };
}
