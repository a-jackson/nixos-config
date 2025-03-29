{ config, ... }:
{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      hide_window_decorations = "yes";
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    documents = "${config.home.homeDirectory}/documents";
    desktop = "${config.home.homeDirectory}/desktop";
    download = "${config.home.homeDirectory}/downloads";
    music = null;
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = null;
    templates = null;
    publicShare = null;
  };

  services.nextcloud-client.enable = true;
  services.nextcloud-client.startInBackground = true;
}
