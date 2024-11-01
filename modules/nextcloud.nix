{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    mkAfter
    ;

  cfg = config.homelab.nextcloud;

  # Cleanup override info
  settings = pkgs.lib.mapAttrsRecursiveCond (s: !s ? "_type") (
    _: value: if value ? "content" then value.content else value
  ) cfg.settings;
in
{

  options.homelab.nextcloud = {

    enable = mkEnableOption "Enable nextcloud";

    apps = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "\n        Nextcloud apps to enable\n      ";
    };

    adminEmail = mkOption {
      type = types.str;
      default = "";
      description = "\n        The email address of the default admin user\n      ";
    };

    adminPasswordFile = mkOption { type = types.path; };

    settings = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "\n        Nextcloud settings to be imported using `occ config:import`\n\n        https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/occ_command.html#config-commands\n      ";
    };
  };

  config = mkIf cfg.enable {

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
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
          forceSSL = true;
          useACMEHost = "andrewjackson.dev";
        };
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      settings.loglevel = 0;
      https = true;
      hostName = "cloud.andrewjackson.dev";
      configureRedis = true;
      extraApps = cfg.apps;
      maxUploadSize = "2G";
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
        echo '${builtins.toJSON settings}' | nextcloud-occ config:import
        # After upgrade make sure DB is up-to-date
        nextcloud-occ db:add-missing-columns -n
        nextcloud-occ db:add-missing-primary-keys -n
        nextcloud-occ db:add-missing-indices -n
        nextcloud-occ db:convert-filecache-bigint -n
      '';
    };
  };
}
