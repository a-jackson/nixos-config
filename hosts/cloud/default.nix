{ config, ... }:
let public_domain = "andrewjackson.dev";
in {
  imports = [ ./hardware-configuration.nix ./networking.nix ];
  ephemeral-btrs = false;
  homelab = {
    impermanence.enable = false;
    systemd-boot = false;
    sops.keyPath = "/etc/ssh/ssh_host_ed25519_key";
    monitoring.enable = true;
    restic = { daily = { paths = [ "/var/lib" ]; }; };
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 ];
  sops.secrets = { cloudflare_credentials = { }; };

  services = {
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = let
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
      in {
        "jellyfin.${public_domain}" = host public_domain "http://apps:8096";
        "requests.${public_domain}" = host public_domain "http://apps:5055";
        "notify.${public_domain}" = host public_domain "http://127.0.0.1:8000";
      };
    };

    gotify = {
      enable = true;
      port = 8000;
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults = { email = "andrew@a-jackson.co.uk"; };
    certs = {
      "${public_domain}" = {
        extraDomainNames = [ "*.${public_domain}" ];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.cloudflare_credentials.path;
        group = config.services.nginx.group;
      };
    };
  };
}
