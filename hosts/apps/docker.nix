{ username, ... }:
{

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };

  users.users.${username}.extraGroups = [ "docker" ];
  sops.secrets = {
    karakeep_env = {
      sopsFile = ./karakeep/karakeep.env;
      format = "dotenv";
      path = "/etc/docker-compose/karakeep/.env";
      group = "docker";
      mode = "0440";
    };
  };

  environment = {
    etc = {
      "docker-compose/immich/docker-compose.yml" = {
        source = ./immich/docker-compose.yml;
      };
      "docker-compose/immich/.env" = {
        source = ./immich/env;
      };
      "docker-compose/collabora/docker-compose.yml" = {
        source = ./collabora/docker-compose.yml;
      };
      "docker-compose/karakeep/docker-compose.yml" = {
        source = ./karakeep/docker-compose.yml;
      };
      "docker-compose/dawarich/docker-compose.yml" = {
        source = ./dawarich/docker-compose.yml;
      };
    };
  };
}
