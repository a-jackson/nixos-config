{ pkgs, config, leng, ... }:
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
    leng.nixosModules.default
  ];

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
  };

  sops.secrets = {
    cloudflare_credentials = {
      sopsFile = ./secrets/common.yaml;
    };
    paperless_env = {
      sopsFile = ./apps/paperless/.env;
      format = "dotenv";
    };
  };

  networking = {
    interfaces = {
      eno1.ipv4.addresses = [{
        address = "192.168.1.205";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "eno1";
    };
  };

  rootDiskLabel = "server";

  nixpkgs.overlays = [
    overlay-jellyseer
  ];

  systemd.services.leng.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";

  services = {
    leng = {
      enable = true;
      configuration = {
        customdnsrecords = [
          "*.ajackson.dev IN A 192.168.1.205"
          "triton.home IN A 192.168.1.75"
        ];
        blocking.sourcesStore = "/var/lib/leng-sources";
      };
    };

    restic_backups = {
      daily = {
        paths = [
          "/persist"
        ];
        repo_key = "restic_apps_repo";
      };
    };

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
          "nextcloud.${public_domain}" = host public_domain "https://triton:4443";
          "audiobooks.${internal_domain}" = host internal_domain "http://triton:13378";
          "bazarr.${internal_domain}" = host internal_domain "http://localhost:6767";
          "radarr.${internal_domain}" = host internal_domain "http://localhost:7878";
          "sonarr.${internal_domain}" = host internal_domain "http://localhost:8989";
          "sabnzbd.${internal_domain}" = host internal_domain "http://triton:8080";
          "cal.${internal_domain}" = host internal_domain "http://pisvrapp03:5232";
          "pics.${internal_domain}" = host internal_domain "http://charon:2283";
          "git.${public_domain}" = host public_domain "http://localhost:3000";
          "paperless.${internal_domain}" = host internal_domain "http://localhost:8000";
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
      nfs-utils
    ];

    persistence."/persist" = {
      directories = [
        "/var/lib/acme"
        "/var/lib/docker"
        "/var/lib/private/jellyseerr"
        "/var/lib/private/leng-sources"
      ];
    };

    etc = {
      "docker-compose/immich/docker-compose.yml" = {
        source = ./apps/immich/docker-compose.yml;
      };
      "docker-compose/immich/.env" = {
        source = ./apps/immich/.env;
      };
      "docker-compose/media/docker-compose.yml" = {
        source = ./apps/media/docker-compose.yml;
      };
      "docker-compose/paperless/docker-compose.yml" = {
        source = ./apps/paperless/docker-compose.yml;
      };
      "docker-compose/paperless/.env" = {
        source = config.sops.secrets.paperless_env.path;
      };
    };
  };

  services.rpcbind.enable = true;
  systemd.mounts =
    let
      tritonMount = folder: {
        type = "nfs";
        mountConfig = {
          Options = "noatime";
        };
        what = "192.168.1.75:/mnt/user/${folder}";
        where = "/mnt/user/${folder}";
      };
    in
    [
      (tritonMount "video")
      (tritonMount "images")
      (tritonMount "appdata")
    ];
  systemd.automounts =
    let
      tritonMount = folder: {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/mnt/user/${folder}";
      };
    in
    [
      (tritonMount "video")
      (tritonMount "images")
      (tritonMount "appdata")
    ];
}
