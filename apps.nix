{ pkgs, config, ... }:
let
  overlay-jellyseer = final: prev: {
    jellyseerr = final.callPackage ./packages/jellyseerr { };
  };
  public_domain = "andrewjackson.dev";
  internal_domain = "ajackson.dev";
in
{
  imports = [
    ./base.nix
    ./modules/ssh.nix
  ];

  sops.secrets = {
    cloudflare_credentials = {
      sopsFile = ./secrets/common.yaml;
    };
  };

  networking = {
    interfaces = {
      enp1s0.ipv4.addresses = [{
        address = "192.168.1.205";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp1s0";
    };
  };

  rootDiskLabel = "server";

  nixpkgs.overlays = [
    overlay-jellyseer
  ];

  services = {
    jellyseerr = {
      enable = true;
      openFirewall = true;
      port = 5055;
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "jellyfin.${public_domain}" = {
          forceSSL = true;
          useACMEHost = "${public_domain}";
          locations."/" = {
            proxyPass = "http://triton:8096";
            proxyWebsockets = true;
          };
        };
        "requests.${public_domain}" = {
          forceSSL = true;
          useACMEHost = "${public_domain}";
          locations."/" = {
            proxyPass = "http://localhost:5055";
            proxyWebsockets = true;
          };
        };
        "nextcloud.${public_domain}" = {
          forceSSL = true;
          useACMEHost = "${public_domain}";
          locations."/" = {
            proxyPass = "https://triton:4443";
            proxyWebsockets = true;
          };
        };
        "audiobooks.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://triton:13378";
            proxyWebsockets = true;
          };
        };
        "bazarr.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://localhost:6767";
            proxyWebsockets = true;
          };
        };
        "radarr.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://localhost:7878";
            proxyWebsockets = true;
          };
        };
        "sonarr.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://localhost:8989";
            proxyWebsockets = true;
          };
        };
        "sabnzbd.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://triton:8080";
            proxyWebsockets = true;
          };
        };
        "cal.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://pisvrapp03:5232";
            proxyWebsockets = true;
          };
        };
        "pics.${internal_domain}" = {
          forceSSL = true;
          useACMEHost = "${internal_domain}";
          locations."/" = {
            proxyPass = "http://pisvrapp03:2283";
            proxyWebsockets = true;
          };
        };
        "git.${public_domain}" = {
          forceSSL = true;
          useACMEHost = "${public_domain}";
          locations."/" = {
            proxyPass = "http://localhost:3000";
            proxyWebsockets = true;
          };
        };
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

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  users.users.andrew.extraGroups = [ "docker" ];

  environment = {
    systemPackages = with pkgs; [
      docker-compose
    ];

    persistence."/persist" = {
      directories = [
        "/var/lib/acme"
        "/var/lib/docker"
        "/var/lib/private/jellyseerr"
      ];
    };

    etc = {
      "docker-compose/media/docker-compose.yml" = {
        source = ./apps/media/docker-compose.yml;
      };
    };
  };

  fileSystems = {
    "/mnt/user/appdata" = {
      device = "triton.home:/mnt/user/appdata";
      fsType = "nfs";
    };
    "/mnt/user/video" = {
      device = "triton.home:/mnt/user/video";
      fsType = "nfs";
    };
  };
}
