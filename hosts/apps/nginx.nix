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
          host =
            acmeHost: port:
            let
              proxyPass = "http://127.0.0.1:${toString port}";
            in
            {
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
          ports = config.homelab.ports;
        in
        {
          "jellyfin.${public_domain}" = host public_domain ports.jellyfin;
          "requests.${public_domain}" = host public_domain ports.jellyseerr;
          "audiobooks.${internal_domain}" = host internal_domain ports.audiobookshelf;
          "bazarr.${internal_domain}" = host internal_domain ports.bazarr;
          "radarr.${internal_domain}" = host internal_domain ports.radarr;
          "sonarr.${internal_domain}" = host internal_domain ports.sonarr;
          "sabnzbd.${internal_domain}" = host internal_domain ports.sabnzbd;
          "pics.${internal_domain}" = host internal_domain ports.immich;
          "paperless.${internal_domain}" = host internal_domain ports.paperless;
          "prometheus.${internal_domain}" = host internal_domain ports.prometheus;
          "grafana.${internal_domain}" = host internal_domain ports.grafana;
          "notes.${internal_domain}" = host internal_domain ports.silverbullet;
          "cameras.${internal_domain}" = {
            forceSSL = true;
            useACMEHost = internal_domain;
          };
          "git.${internal_domain}" = host internal_domain ports.forgejo;
          "pdf.${internal_domain}" = host internal_domain ports.stirling-pdf;
          "pitpat.${internal_domain}" = host internal_domain ports.pitpat;
          "mealie.${internal_domain}" = host internal_domain ports.mealie;
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
