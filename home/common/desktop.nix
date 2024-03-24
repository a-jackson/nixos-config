{ pkgs, config, ... }: {
  programs.kitty = {
    enable = true;
    font.name = "Fira Code";
    theme = "Catppuccin-Mocha";
    settings = { hide_window_decorations = "yes"; };
  };

  home.packages = with pkgs; [ neovide ];

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
