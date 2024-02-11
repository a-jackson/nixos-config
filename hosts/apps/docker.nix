{ pkgs, ... }: {

  sops.secrets = {
    paperless_env = {
      sopsFile = ./paperless/.env;
      format = "dotenv";
      path = "/etc/docker-compose/paperless/.env";
    };
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };

  users.users.andrew.extraGroups = [ "docker" ];

  environment = {
    systemPackages = with pkgs; [
      docker-compose
    ];

    etc = {
      "docker-compose/immich/docker-compose.yml" = {
        source = ./immich/docker-compose.yml;
      };
      "docker-compose/immich/.env" = {
        source = ./immich/.env;
      };
      "docker-compose/paperless/docker-compose.yml" = {
        source = ./paperless/docker-compose.yml;
      };
    };
  };
}
