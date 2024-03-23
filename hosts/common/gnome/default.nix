{ username, pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      xkb.layout = "gb";
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

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.flatpak.enable = true;
  environment.etc = {
    "flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
      url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
    };
  };

  users.users."${username}".extraGroups = [ "flatpak" ];
}
