{ lib, config, ... }:
let
  cfg = config.homelab.multimedia;
  ports = config.homelab.ports;
in
{
  options.homelab.multimedia = with lib; {
    group = mkOption {
      type = types.str;
      default = "multimedia";
    };
  };

  config = {
    users.groups."${cfg.group}" = { };
    users.users.andrew.extraGroups = [ cfg.group ];

    systemd.tmpfiles.rules = [ "d /data/media 0770 - ${cfg.group} - -" ];
    systemd.services.jellyfin.environment.JELLYFIN_PublishedServerUrl =
      "https://jellyfin.andrewjackson.dev";

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
      jellyseerr = {
        enable = true;
        openFirewall = true;
        port = ports.jellyseerr;
      };
      jellyfin = {
        enable = true;
        group = cfg.group;
        openFirewall = true;
      };
    };

    fileSystems."/data" = {
      device = "/dev/disk/by-label/${config.homelab.root.diskLabel}";
      fsType = "btrfs";
      options = [
        "subvol=data"
        "compress=zstd"
      ];
    };
  };
}
