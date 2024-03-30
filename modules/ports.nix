{ lib, ... }:
let inherit (lib) mkOption types;
in {
  options.homelab.ports = mkOption { type = types.attrsOf types.int; };

  config = {
    homelab.ports = {
      sonarr = 8989;
      jellyfin = 8096;
      jellyseerr = 5055;
      audiobookshelf = 13378;
      bazarr = 6767;
      radarr = 7878;
      sabnzbd = 8181;
      immich = 2283;
      paperless = 8000;
      prometheus = 9090;
      grafana = 3000;
      forgejo = 3600;
      silverbullet = 3001;
      loki = 3100;
      smartctl = 9633;
      node = 9100;
      promtail = 28183;
    };
  };
}
