{ username, pkgs, ... }: {

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

    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  programs.dconf.enable = true;

  users.users.${username}.extraGroups = [ "scanner" "lp" ];

  environment.systemPackages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.en_GB-ise
    libsForQt5.skanlite
  ];
}
