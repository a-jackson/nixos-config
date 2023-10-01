{ pkgs, home-manager, impermanence, config, ... }:
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
    imports = [ impermanence.nixosModules.home-manager.impermanence ];

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

      ssh = {
        enable = true;
      };
    };

    home.persistence."/persist/home/andrew" = {
      allowOther = true;
      directories = [
        "repos"
        ".local/share/keyrings"
        ".ssh"
        ".config/gh"
      ];
    };

    home.stateVersion = "23.05";
  };
}
