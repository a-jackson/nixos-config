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
    storageDriver = "btrfs";
  };

  users.users.andrew.extraGroups = [ "docker" ];

  environment = {
    systemPackages = with pkgs; [
      docker-compose
    ];

    persistence."/persist" = {
      directories = [
        "/var/lib/docker"
      ];
    };

    etc = {
      "docker-compose/immich/docker-compose.yml" = {
        source = ./immich/docker-compose.yml;
      };
      "docker-compose/immich/.env" = {
        source = ./immich/.env;
      };
      "docker-compose/media/docker-compose.yml" = {
        source = ./media/docker-compose.yml;
      };
      "docker-compose/paperless/docker-compose.yml" = {
        source = ./paperless/docker-compose.yml;
      };
    };
  };
}