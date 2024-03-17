{ lib, ... }:
let inherit (lib) mkOption types;
in {
  options.homelab.ports = {
    sonarr = mkOption {
      type = types.int;
      default = 8989;
    };
    jellyfin = mkOption {
      type = types.int;
      default = 8096;
    };
    jellyseerr = mkOption {
      type = types.int;
      default = 5055;
    };
    audiobookshelf = mkOption {
      type = types.int;
      default = 13378;
    };
    bazarr = mkOption {
      type = types.int;
      default = 6767;
    };
    radarr = mkOption {
      type = types.int;
      default = 7878;
    };
    sabnzbd = mkOption {
      type = types.int;
      default = 8181;
    };
    immich = mkOption {
      type = types.int;
      default = 2283;
    };
    paperless = mkOption {
      type = types.int;
      default = 8000;
    };
    prometheus = mkOption {
      type = types.int;
      default = 9090;
    };
    grafana = mkOption {
      type = types.int;
      default = 3000;
    };
    forgejo = mkOption {
      type = types.int;
      default = 3600;
    };
    silverbullet = mkOption {
      type = types.int;
      default = 3001;
    };
    loki = mkOption {
      type = types.int;
      default = 3100;
    };
    smartctl = mkOption {
      type = types.int;
      default = 9633;
    };
    node = mkOption {
      type = types.int;
      default = 9100;
    };
    promtail = mkOption {
      type = types.int;
      default = 28183;
    };
  };
}
