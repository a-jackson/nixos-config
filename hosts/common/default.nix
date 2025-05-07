{
  pkgs,
  nixpkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./sops.nix
    ./user.nix
    ./auto-upgrade.nix
    ./nvim.nix
    ../../modules
  ];
  options.homelab = with lib; {
    systemd-boot = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    boot.loader = lib.mkIf config.homelab.systemd-boot {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      useDHCP = nixpkgs.lib.mkDefault true;
      firewall.enable = true;
      networkmanager.enable = true;
    };

    fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

    services.tailscale.enable = true;

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      keyMap = "uk";
    };

    programs.fuse.userAllowOther = true;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      extraOptions = ''
        download-buffer-size = 524288000
      '';

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      jq
      lsof
      hdparm
      du-dust
      btrfs-progs
    ];

    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "23.05";
  };
}
