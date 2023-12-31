{ lib, config, ... }:
with lib;
let
  cfg = config.services.restic_backups;
in
{
  options = {
    services.restic_backups = mkOption {
      default = { };
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          paths = mkOption {
            type = types.listOf types.str;
          };
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
      restic_password = {
        sopsFile = ../secrets/restic.yaml;
      };
      restic_env = {
        sopsFile = ../secrets/restic.yaml;
      };
      restic_repo = {
        sopsFile = ../secrets/restic.yaml;
      };
    };

    services.restic.backups = (
      (flip mapAttrs' cfg (name: backupCfg:
        nameValuePair "${name}" {
          initialize = true;

          environmentFile = config.sops.secrets.restic_env.path;
          repositoryFile = config.sops.secrets.restic_repo.path;
          passwordFile = config.sops.secrets.restic_password.path;

          paths = backupCfg.paths;
          exclude = backupCfg.exclude;

          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--host ${config.networking.hostName}"
          ];
        }))
    );

  };
}
