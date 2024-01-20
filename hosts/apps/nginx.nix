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
            };
          };
        in
        {
          "jellyfin.${public_domain}" = host public_domain "http://triton:8096";
          "requests.${public_domain}" = host public_domain "http://localhost:5055";
          "audiobooks.${internal_domain}" = host internal_domain "http://triton:13378";
          "bazarr.${internal_domain}" = host internal_domain "http://localhost:6767";
          "radarr.${internal_domain}" = host internal_domain "http://localhost:7878";
          "sonarr.${internal_domain}" = host internal_domain "http://localhost:8989";
          "sabnzbd.${internal_domain}" = host internal_domain "http://triton:8080";
          "pics.${internal_domain}" = host internal_domain "http://localhost:2283";
          "paperless.${internal_domain}" = host internal_domain "http://localhost:8000";
          "prometheus.${internal_domain}" = host internal_domain "http://localhost:${toString config.services.prometheus.port}";
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

  environment = {
    persistence."/persist" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}
