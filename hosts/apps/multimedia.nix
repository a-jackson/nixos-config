{ lib, config, ... }:
let
  cfg = config.homelab.multimedia;

  sonarr-overlay = final: prev: {
    sonarr = final.callPackage ../../packages/sonarr { };
  };
in
{
  options.homelab.multimedia = with lib; {
    group = mkOption {
      type = types.str;
      default = "multimedia";
    };
  };

  config = {
    nixpkgs.overlays = [ sonarr-overlay ];

    users.groups."${cfg.group}" = { };
    users.users.andrew.extraGroups = [ cfg.group ];

    systemd.tmpfiles.rules = [
      "d /data/media 0770 - ${cfg.group} - -"
    ];

    services = {
      sonarr = {
        enable = true;
        group = cfg.group;
      };
      radarr = {
        enable = true;
        group = cfg.group;
      };
      bazarr = {
        enable = true;
        group = cfg.group;
      };
      sabnzbd = {
        enable = true;
        group = cfg.group;
      };
    };

    environment.persistence."/persist" = {
      directories = [
        {
          directory = "/var/lib/sonarr";
          user = config.services.sonarr.user;
          group = config.services.sonarr.group;
        }
        {
          directory = "/var/lib/radarr";
          user = config.services.radarr.user;
          group = config.services.radarr.group;
        }
        {
          directory = "/var/lib/bazarr";
          user = config.services.bazarr.user;
          group = config.services.bazarr.group;
        }
        {
          directory = "/var/lib/sabnzbd";
          user = config.services.sabnzbd.user;
          group = config.services.sabnzbd.group;
        }
      ];
    };

    fileSystems."/data" = {
      device = "/dev/disk/by-label/${config.rootDiskLabel}";
      fsType = "btrfs";
      options = [ "subvol=data" "compress=zstd" ];
    };
  };
}
