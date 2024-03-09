{ ... }: {
  services.forgejo = {
    enable = true; 
    settings = {
      server = {
        DISABLE_SSH = true;
        DOMAIN = "git.ajackson.dev";
        HTTP_PORT = 3600;
        COOKIE_SECURE = true;
        ROOT_URL = "https://git.ajackson.dev/";
      };
    };
  };
}
 
