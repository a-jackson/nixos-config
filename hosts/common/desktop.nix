{ pkgs, username, ... }:
{
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  users.users.${username}.extraGroups = [
    "scanner"
    "lp"
    "flatpak"
  ];

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
}
