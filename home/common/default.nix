{ pkgs, lib, config, ... }:
{
  imports = [
    ./shell.nix
  ];

  home.persistence."/persist/home/${config.home.username}" = {
    allowOther = true;
    directories = [
      "repos"
      ".gnupg"
      ".ssh"
      ".cache/flatpak"
      ".local/share/flatpak"
      "documents"
      "desktop"
      "downloads"
    ];
  };

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
