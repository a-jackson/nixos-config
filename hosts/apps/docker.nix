{ username, ... }:
{

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };

  users.users.${username}.extraGroups = [ "docker" ];

  environment = {
    etc = {
      "docker-compose/immich/docker-compose.yml" = {
        source = ./immich/docker-compose.yml;
      };
      "docker-compose/immich/.env" = {
        source = ./immich/env;
      };
    };
  };
}
