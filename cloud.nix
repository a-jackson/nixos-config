{ config, ... }:
let
  sops.secrets = {
    cloudflare_credentials = {
      sopsFile = ../secrets/common.yaml;
    };
  };

  domain = "andrewjackson.dev";
in
{
  inputs = [
    ./base.nix
  ];

  services.ngnix = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."jellyfin.${domain}" = {
      enableACME = true;
      forceSSL = true;
      useACMEHost = "${domain}";
      locations."/" = {
        proxyPass = "http://triton:8096";
        proxyWebSockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    email = "andrew@a-jackson.co.uk";
    certs = {
      "${domain}" = {
        extraDomainNames = [ "*.${domain}" ];
        dnsProvider = cloudflare;
        credentialsFile = config.sops.secrets.cloudflare_credentials.path;
      };
    };
  };
}
