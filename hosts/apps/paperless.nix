{ ... }: {
  services = {
    paperless = {
      enable = true;
      port = 8000;
      address = "127.0.0.1";
      settings = {
        PAPERLESS_FILENAME_FORMAT = "{created_year}/{correspondent}/{title}";
        PAPERLESS_CONSUMER_RECURSIVE = "true";
      };
    };
  };
}

