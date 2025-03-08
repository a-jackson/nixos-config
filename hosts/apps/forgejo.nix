{ config, pkgs, ... }:
{
  sops.secrets = {
    "forgejo/mailer_password" = {
      sopsFile = ./secrets.yaml;
      owner = config.services.forgejo.user;
      mode = "400";
    };
    "forgejo/runner_token" = {
      sopsFile = ./secrets.yaml;
    };
  };

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
      service.DISABLE_REGISTRATION = true;
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      mailer = {
        ENABLED = true;
        SMTP_ADDR = "mail.example.com";
        FROM = "git@ajackson.dev";
        USER = "andrew@andrewjackson.dev";
      };
    };
    secrets.mailer.PASSWD = config.sops.secrets."forgejo/mailer_password".path;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = "apps";
      url = "https://git.ajackson.dev";
      # Obtaining the path to the runner token file may differ
      # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.sops.secrets."forgejo/runner_token".path;
      labels = [
        "ubuntu-latest:docker://node:22-bookworm"
      ];
    };
  };
}
