{ pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;
      layout = "gb";
      libinput.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.dconf.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.en_GB-ise
  ];
}
