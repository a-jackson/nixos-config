{ pkgs, lib, config, ... }:

with lib;
with builtins;

let
  cfg = config.nextcloud;

  # Cleanup override info
  settings = pkgs.lib.mapAttrsRecursiveCond
    (s: ! s ? "_type")
    (_: value: if value ? "content" then value.content else value)
    cfg.settings;

in
{

  options.nextcloud = {

    enable = mkEnableOption "Enable nextcloud";

    apps = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "
        Nextcloud apps to enable
      ";
    };

    adminEmail = mkOption {
      type = types.str;
      default = "";
      description = "
        The email address of the default admin user
      ";
    };

    adminPasswordFile = mkOption {
      type = types.path;
    };

    settings = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "
        Nextcloud settings to be imported using `occ config:import`

        https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/occ_command.html#config-commands
      ";
    };

  };

  config = mkIf cfg.enable {

    services.mysql = {
      enable = true;
      package = pkgs.mysql;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "nextcloud.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "cloud.andrewjackson.dev" = {
          default = true;
          forceSSL = true;
          useACMEHost = "andrewjackson.dev";
        };
        "office.andrewjackson.dev" = {
          forceSSL = true;
          useACMEHost = "andrewjackson.dev";
          locations = {
            # static files
            "^~ /browser" = {
              proxyPass = "http://localhost:9980";
              extraConfig = ''
                proxy_set_header Host $host;
              '';
            };
            # WOPI discovery URL
            "^~ /hosting/discovery" = {
              proxyPass = "http://localhost:9980";
              extraConfig = ''
                proxy_set_header Host $host;
              '';
            };

            # Capabilities
            "^~ /hosting/capabilities" = {
              proxyPass = "http://localhost:9980";
              extraConfig = ''
                proxy_set_header Host $host;
              '';
            };

            # download, presentation, image upload and websocket
            "~ ^/(c|l)ool" = {
              proxyPass = "http://localhost:9980";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_set_header Host $host;
                proxy_read_timeout 36000s;
              '';
            };

            # Admin Console websocket
            "^~ /cool/adminws" = {
              proxyPass = "http://localhost:9980";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_set_header Host $host;
                proxy_read_timeout 36000s;
              '';
            };
          };
        };
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      extraOptions.loglevel = 0;
      https = true;
      hostName = "cloud.andrewjackson.dev";
      configureRedis = true;
      extraApps = cfg.apps;
      caching = {
        apcu = true;
      };
      config = {
        dbtype = "mysql";
        adminuser = "andrew";
        adminpassFile = cfg.adminPasswordFile;
      };
    };

    # This is to do the initial nextcloud setup only when Mysql and
    # Redis are ready. We need to add this because mysql is on the same
    # host.
    systemd.services.nextcloud-setup = {
      serviceConfig.RemainAfterExit = true;
      partOf = [ "phpfpm-nextcloud.service" ];
      after = [ "mysql.service" ];
      requires = [ "mysql.service" ];
      script = mkAfter ''
        nextcloud-occ user:setting admin settings email ${cfg.adminEmail}
        echo '${toJSON settings}' | nextcloud-occ config:import
        # After upgrade make sure DB is up-to-date
        nextcloud-occ db:add-missing-columns -n
        nextcloud-occ db:add-missing-primary-keys -n
        nextcloud-occ db:add-missing-indices -n
        nextcloud-occ db:convert-filecache-bigint -n
      '';
    };

    virtualisation.oci-containers = {
      # Since 22.05, the default driver is podman but it doesn't work
      # with podman. It would however be nice to switch to podman.
      backend = "docker";
      containers.collabora = {
        image = "collabora/code";
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "collabora/code";
          imageDigest = "sha256:46534fe0ed6208797c6711f29d5e85a8a3e554c9debbfe7ff0587b1f2710465e";
          sha256 = "sha256-MHs7xwmlnmIdInyvXfiLb+NotxAEG8XNh41aSzKgcnc=";
        };
        ports = [ "9980:9980" ];
        environment = {
          aliasgroup1 = "https://cloud.andrewjackson.dev:443";
          extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
        };
        extraOptions = [ "--cap-add" "MKNOD" ];
      };
    };
  };
}
