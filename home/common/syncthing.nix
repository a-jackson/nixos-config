{ ... }:
{
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  home.persistence."/persist/home/andrew" = {
    allowOther = true;
    directories = [
      ".config/syncthing"
    ];
  };
}
