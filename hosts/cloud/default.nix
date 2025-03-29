{ config, lib, ... }:
let
  public_domain = "andrewjackson.dev";
in
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/dns.nix
  ];

  nixpkgs.overlays = [
    (
      self: super:

      {
        immich-public-proxy = super.immich-public-proxy.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches or [ ] ++ [
            (self.fetchpatch {
              url = "https://github.com/a-jackson/immich-public-proxy/commit/0c9225e6b8db34bcdd1202f36f8dc5996dfdede5.patch";
              sha256 = "sha256-YeTm32KDBINM7VCHDt8kqs96Qz5/dPYNctqKuHYQ2tE=";
              stripLen = 1;
            })
          ];
        });
      })
  ];

  homelab = {
    nvim.enable = lib.mkForce false;
    homeType = lib.mkForce "minimal";
    root = {
      ephemeralBtrfs.enable = false;
    };

    impermanence.enable = false;

    systemd-boot = false;
    sops.keyPath = "/etc/ssh/ssh_host_ed25519_key";
    monitoring.enable = true;
    monitoring.smartctl.enable = false;
    restic = {
      daily = {
        paths = [ "/var/lib" ];
      };
    };

    dns = {
      enable = true;
      virtualHosts = {
        target = "100.92.22.51";
      };
    };
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 ];
  sops.secrets = {
    cloudflare_credentials = { };
  };

  networking.useDHCP = lib.mkForce false;

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
          "jellyfin.${public_domain}" = host public_domain "http://apps:8096";
          "requests.${public_domain}" = host public_domain "http://apps:5055";
          "notify.${public_domain}" = host public_domain "http://127.0.0.1:8000";
          "pics.${public_domain}" = host public_domain "http://127.0.0.1:3000";
          "ntfy.${public_domain}" = host public_domain "http://127.0.0.1:8888";
        };
    };

    gotify = {
      enable = true;
      environment.GOTIFY_SERVER_PORT = 8000;
    };

    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.${public_domain}";
        listen-http = "127.0.0.1:8888";
        behind-proxy = true;
        smtp-server-listen = ":2525";
        smtp-server-domain = "ntfy.ajackson.dev";
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";
      };
    };

    immich-public-proxy = {
      enable = true;
      port = 3000;
      immichUrl = "https://pics.ajackson.dev";
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
    };
  };
}
