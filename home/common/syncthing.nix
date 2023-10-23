{ config, ... }:
{
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  home.persistence."/persist${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".config/syncthing"
    ];
  };
}
