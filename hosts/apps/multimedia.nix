{ lib, config, ... }:
let
  cfg = config.homelab.multimedia;
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
      jellyseerr = {
        enable = true;
        openFirewall = true;
        port = 5055;
      };
      jellyfin = {
        enable = true;
        group = cfg.group;
        openFirewall = true;
      };
    };

    fileSystems."/data" = {
      device = "/dev/disk/by-label/${config.rootDiskLabel}";
      fsType = "btrfs";
      options = [ "subvol=data" "compress=zstd" ];
    };
  };
}
