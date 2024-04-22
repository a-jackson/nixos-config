{ pkgs, config, ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "Fira Code";
    theme = "Catppuccin-Mocha";
    settings = {
      hide_window_decorations = "yes";
    };
  };

  home.packages = with pkgs; [
    neovide
    protonmail-bridge
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

  systemd.user.services = {
    protonmail-bridge = {
      Unit = {
        Description = "Protonmail Bridge";
        After = [ "network.target" ];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
        Restart = "always";
        RestartSec = 30;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  services.nextcloud-client.enable = true;
}
