{ config, ... }:
let
  public_domain = "andrewjackson.dev";
  internal_domain = "ajackson.dev";
in
{
  sops.secrets = {
    cloudflare_credentials = { };
  };

  services = {
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts =
        let
          host = acmeHost: proxyPass: {
            forceSSL = true;
            useACMEHost = acmeHost;
            locations."/" = {
              proxyPass = proxyPass;
              proxyWebsockets = true;
              extraConfig = ''
                  client_max_body_size 0;
              '';
            };
          };
        in
        {
          "jellyfin.${public_domain}" = host public_domain "http://127.0.0.1:8096";
          "requests.${public_domain}" = host public_domain "http://127.0.0.1:5055";
          "audiobooks.${internal_domain}" = host internal_domain "http://127.0.0.1:13378";
          "bazarr.${internal_domain}" = host internal_domain "http://127.0.0.1:6767";
          "radarr.${internal_domain}" = host internal_domain "http://127.0.0.1:7878";
          "sonarr.${internal_domain}" = host internal_domain "http://127.0.0.1:8989";
          "sabnzbd.${internal_domain}" = host internal_domain "http://127.0.0.1:8181";
          "pics.${internal_domain}" = host internal_domain "http://127.0.0.1:2283";
          "paperless.${internal_domain}" = host internal_domain "http://127.0.0.1:8000";
          "prometheus.${internal_domain}" = host internal_domain "http://127.0.0.1:${toString config.services.prometheus.port}";
          "grafana.${internal_domain}" = host internal_domain "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          "notes.${internal_domain}" = host internal_domain "http://127.0.0.1:3001";
        };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "andrew@a-jackson.co.uk";
    };
    certs = {
      "${public_domain}" = {
        extraDomainNames = [ "*.${public_domain}" ];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.cloudflare_credentials.path;
        group = config.services.nginx.group;
      };
      "${internal_domain}" = {
        extraDomainNames = [ "*.${internal_domain}" ];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.cloudflare_credentials.path;
        group = config.services.nginx.group;
      };
    };
  };
}
