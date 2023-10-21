{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
  };

  home.persistence."/persist/home/andrew" = {
    allowOther = true;
    directories = [
      ".mozilla"
    ];
  };
}
