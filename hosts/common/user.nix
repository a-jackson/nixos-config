{ pkgs, home-manager, impermanence, config, lib, ... }: {
  imports = [ home-manager.nixosModules.home-manager ];

  sops.secrets.password = { neededForUsers = true; };

  users = {
    users.andrew = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets.password.path;
    };

    mutableUsers = false;
    users.root.hashedPasswordFile = config.sops.secrets.password.path;
    users.root.shell = pkgs.fish;
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

  home-manager.users = let hostname = config.networking.hostName;
  in {
    andrew = {
      imports = [
        ../../home/${hostname}.nix
        {
          home = {
            username = lib.mkDefault "andrew";
            homeDirectory = lib.mkDefault "/home/andrew";
            stateVersion = "23.05";
          };
        }
      ];
    };
    root = {
      imports = [ ../../home/common { home = { stateVersion = "23.05"; }; } ];
    };
  };
}
