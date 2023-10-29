{ pkgs, home-manager, impermanence, config, lib, ... }:
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
      hashedPasswordFile = config.sops.secrets.password.path;
    };

    mutableUsers = false;
    users.root.hashedPasswordFile = config.sops.secrets.password.path;
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

  home-manager.users.andrew =
    let
      hostname = config.networking.hostName;
    in
    {
      imports = [
        impermanence.nixosModules.home-manager.impermanence
        ../home/${hostname}.nix
        {
          home = {
            username = lib.mkDefault "andrew";
            homeDirectory = lib.mkDefault "/home/andrew";
            stateVersion = "23.05";
          };
        }
      ];
    };
}
