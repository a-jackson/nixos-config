{ pkgs, config, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
  };

  home.persistence."/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".mozilla"
    ];
  };
}
