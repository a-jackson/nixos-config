{ config, ... }:
{
  sops.secrets = {
    nextcloud_password = {
      sopsFile = ./secrets.yaml;
      owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
    };
  };

  services = {
    mysqlBackup = {
      enable = true;
      databases = [ "nextcloud" ];
      location = "/persist/backups/mysql";
    };

    nginx.virtualHosts."office.andrewjackson.dev" = {
      forceSSL = true;
      useACMEHost = "andrewjackson.dev";
      locations =
        let
          proxyPass = "http://localhost:9980";
          proxy = {
            inherit proxyPass;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
            '';
          };
          socket = {
            inherit proxyPass;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_read_timeout 36000s;
            '';
          };
        in
        {
          "^~ /browser" = proxy;
          "^~ /hosting/discovery" = proxy;
          "^~ /hosting/capabilities" = proxy;
          "~ ^/cool/(.*)/ws$" = socket;
          "~ ^/(c|l)ool" = proxy;
          "~ /cool/adminws" = socket;
        };
    };
  };

  homelab.nextcloud = {
    enable = true;
    adminEmail = "andrew@a-jackson.co.uk";
    adminPasswordFile = config.sops.secrets.nextcloud_password.path;
    settings = {
      system = {
        appstoreenabled = true;
      };
      apps.core.backgroundjobs_mode = "cron";
      # This avoids users to see the email of all others users when
      # they try to share a file.
      apps.core.shareapi_only_share_with_group_members = "yes";
      apps.registration.admin_approval_required = "yes";
      # Default quota for new users
      apps.files.default_quota = "40GB";
      apps.richdocuments.wopi_url = "https://office.andrewjackson.dev";
      # This is to disable the rich workspace feature because of this issue:
      # https://help.nextcloud.com/t/loading-spinner-in-files-overview/80393
      apps.text.workspace_available = "0";
    };
  };
}
