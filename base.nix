{ pkgs, nixpkgs, ... }:
{
  imports = [
    ./modules/sops.nix
    ./modules/user.nix
    ./modules/ephemeral-btrfs.nix
    ./modules/auto-upgrade.nix
    ./impermanence/system.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    useDHCP = nixpkgs.lib.mkDefault true;
    firewall.enable = true;
    networkmanager.enable = true;
  };

  services.tailscale.enable = true;
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  programs.fuse.userAllowOther = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      trusted-users = [ "root" "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}
