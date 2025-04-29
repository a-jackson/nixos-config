{
  pkgs,
  lib,
  config,
  ...
}:
{
  services = {
    paperless = {
      enable = true;
      port = config.homelab.ports.paperless;
      address = "127.0.0.1";
      settings = {
        PAPERLESS_FILENAME_FORMAT = "{created_year}/{correspondent}/{title}";
        PAPERLESS_CONSUMER_RECURSIVE = "true";
        PAPERLESS_URL = "https://paperless.ajackson.dev";
        LD_LIBRARY_PATH = "${lib.getLib pkgs.mkl}/lib";
      };
    };

    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          security = "user";
          "server string" = "apps";
          "netbios name" = "apps";
          "hosts allow" = "192.168.1.0/24 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
        };
        consume = {
          path = config.services.paperless.consumptionDir;
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "paperless";
          "force group" = "paperless";
        };
      };
    };
  };
}
