{ pkgs, ... }:
{

  services = {
    xserver = {
      enable = true;
      xkb.layout = "gb";
      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
    };

    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [ libsForQt5.skanlite ];
}
