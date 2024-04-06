{ config, ... }:
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        DISABLE_SSH = true;
        DOMAIN = "git.ajackson.dev";
        HTTP_PORT = config.homelab.ports.forgejo;
        COOKIE_SECURE = true;
        ROOT_URL = "https://git.ajackson.dev/";
      };
    };
  };
}
