{ pkgs, home-manager, config, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  sops.secrets.password = {
    sopsFile = ../secrets/common.yaml;
    neededForUsers = true;
  };

  users = {
    users.andrew = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
      ];
      passwordFile = config.sops.secrets.password.path;
    };

    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.password.path;
  };

  programs = {
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };

  home-manager.users.andrew = {
    programs = {
      git = {
        enable = true;
        userEmail = "andrew@a-jackson.co.uk";
        userName = "Andrew Jackson";
      };

      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
      };
    };

    home.stateVersion = "23.05";
  };
}
