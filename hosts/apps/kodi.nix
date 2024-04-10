{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.kodi.enable = true;
    desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [ jellyfin ]);
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "kodi";
      lightdm.autoLogin.timeout = 3;
    };
  };

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
