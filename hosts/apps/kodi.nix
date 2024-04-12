{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.kodi.enable = true;
    desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [ jellyfin ]);
    displayManager.lightdm.autoLogin.timeout = 3;
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kodi";

  users.extraUsers.kodi.isNormalUser = true;
  users.extraUsers.kodi.extraGroups = [ "audio" ];

  hardware.pulseaudio.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Name = "Hello";
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };
}
