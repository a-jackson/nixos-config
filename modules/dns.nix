{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.homelab.dns;
in {
  options.homelab.dns = {
    enable = mkEnableOption "Enable DNS Server";
    lanHosts = mkOption {
      description = "hostnames and their IP addresses";
      type = types.attrsOf types.str;
    };
    virtualHosts.target = mkOption {
      description = "IP address of the virtual hosts";
      type = types.str;
    };
    virtualHosts.hosts = mkOption {
      type = types.listOf types.str;
      description = "List of the virutal hostnames";
    };
  };

  config = mkIf cfg.enable {
    homelab.dns = {
      lanHosts = {
        "nas.home" = "192.168.1.75";
        "apps.home" = "192.168.1.205";
        "pisvrapp03.home" = "192.168.1.203";
      };

      virtualHosts.hosts = [
        "audiobooks.ajackson.dev"
        "bazarr.ajackson.dev"
        "cameras.ajackson.dev"
        "cloud.andrewjackson.dev"
        "git.ajackson.dev"
        "grafana.ajackson.dev"
        "jellyfin.andrewjackson.dev"
        "notes.ajackson.dev"
        "office.andrewjackson.dev"
        "paperless.ajackson.dev"
        "pics.ajackson.dev"
        "prometheus.ajackson.dev"
        "radarr.ajackson.dev"
        "requests.andrewjackson.dev"
        "sabnzbd.ajackson.dev"
        "sonarr.ajackson.dev"
      ];
    };

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      openFirewall = true;
      settings = let
        lanHosts = builtins.map (domain: {
          inherit domain;
          answer = cfg.lanHosts.${domain};
        }) (builtins.attrNames cfg.lanHosts);

        virtualHosts = builtins.map (domain: {
          inherit domain;
          answer = cfg.virtualHosts.target;
        }) cfg.virtualHosts.hosts;

        rewrites = lanHosts ++ virtualHosts;
      in {
        bind_host = "0.0.0.0";
        bind_port = 3500;
        http = { address = "0.0.0.0:3500"; };
        dns = {
          bootstrap_dns = [ "9.9.9.9" ];
          bind_host = "0.0.0.0";
          inherit rewrites;
        };
      };
    };

    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
