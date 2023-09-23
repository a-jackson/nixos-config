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
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
      ];
      passwordFile = config.sops.secrets.password.path;
    };

    mutableUsers = false;
    users.root.passwordFile = config.sops.secrets.password.path;
  };

  home-manager.users.andrew = {
    programs.git = {
      enable = true;
      userEmail = "andrew@a-jackson.co.uk";
      userName = "Andrew Jackson";
    };

    home.stateVersion = "23.05";
  };
}
