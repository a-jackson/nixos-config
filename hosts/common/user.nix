{
  pkgs,
  home-manager,
  stylix,
  username,
  config,
  lib,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

  sops.secrets.password = {
    neededForUsers = true;
  };

  users = {
    users."${username}" = {
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

  home-manager.users =
    let
      type = config.homelab.homeType;
    in
    {
      "${username}" = {
        imports = [
          stylix.homeManagerModules.stylix
          ../../home/${type}.nix
          {
            home = {
              inherit username;
              homeDirectory = lib.mkDefault "/home/${username}";
              stateVersion = "23.05";
            };
          }
        ];
      };
      root = {
        imports = [
          ../../home/common
          {
            home = {
              stateVersion = "23.05";
            };
          }
        ];
      };
    };
}
