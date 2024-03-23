{ lib, pkgs, config, ... }:
with lib;
let cfg = config.homelab.restic;
in {
  options = {
    homelab.restic = mkOption {
      default = { };
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          paths = mkOption { type = types.listOf types.str; };
          exclude = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      }));
    };
  };

  config = {
    sops.secrets = {
      "restic/password" = { };
      "restic/env" = { };
      "restic/repo" = { };
    };

    services.restic.backups = ((flip mapAttrs' cfg (name: backupCfg:
      nameValuePair "${name}" {
        initialize = true;

        environmentFile = config.sops.secrets."restic/env".path;
        repositoryFile = config.sops.secrets."restic/repo".path;
        passwordFile = config.sops.secrets."restic/password".path;

        paths = backupCfg.paths;
        exclude = backupCfg.exclude;

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--host ${config.networking.hostName}"
        ];
      })));

    systemd.services = ((flip mapAttrs' cfg (name: backupCfg:
      nameValuePair "restic-backups-${name}" {
        serviceConfig.ExecStopPost = [
          (pkgs.writeShellScript "backupsCompleted" ''
            if [[ "$EXIT_STATUS" != "0" ]]; then
              logs=$(journalctl -u "restic-backups-${name}.service" --lines 20)
              title="${config.networking.hostName} backups"
              message="Backup failed with result '$SERVICE_RESULT'\n\n\`\`\`\n$logs\n\`\`\`\n"

              ${config.homelab.notifications.sendNotification} \
                --title "$title" \
                --message "$message" \
                --markdown
              fi
          '')
        ];
      })));
  };
}
