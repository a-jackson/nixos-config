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
      "restic/password" = { };
      "restic/env" = { };
      "restic/repo" = { };
    };

    services.restic.backups = (
      (flip mapAttrs' cfg (name: backupCfg:
        nameValuePair "${name}" {
          initialize = true;

          environmentFile = config.sops.secrets."restic/env".path;
          repositoryFile = config.sops.secrets."restic/repo".path;
          passwordFile = config.sops.secrets."restic/password".path;

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
