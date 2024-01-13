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
    ./modules/nextcloud.nix
    leng.nixosModules.default
  ];

  sops.secrets = {
    cloudflare_credentials = {
      sopsFile = ./secrets/common.yaml;
    };
    paperless_env = {
      sopsFile = ./apps/paperless/.env;
      format = "dotenv";
    };
    nextcloud_password = {
      sopsFile = ./secrets/apps.yaml;
      owner = config.systemd.services.nextcloud-setup.serviceConfig.User;
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

    firewall = {
      allowedTCPPorts = [ 443 ];
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
      '';
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eno1";
    };
  };

  rootDiskLabel = "server";

  nixpkgs.overlays = [
    overlay-jellyseer
  ];

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
          "prometheus.${internal_domain}" = host internal_domain "http://localhost:${toString config.services.prometheus.port}";
        };
    };

    prometheus = {
      enable = true;

      exporters = {
        smartctl = {
          enable = true;
        };
      };

      scrapeConfigs = [{
        job_name = "apps_disk";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
          ];
        }];
      }];
    };

    mysqlBackup = {
      enable = true;
      databases = [
        "nextcloud"
      ];
      location = "/persist/backups/mysql";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
  '';

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

  nextcloud = {
    enable = true;
    adminEmail = "andrew@a-jackson.co.uk";
    adminPasswordFile = config.sops.secrets.nextcloud_password.path;
    settings = {
      system = {
        appstoreenabled = true;
        # mail_smtphost = "127.0.0.1:25";
        # mail_domain = "markas.fr";
      };
      apps.core.backgroundjobs_mode = "cron";
      # This avoids users to see the email of all others users when
      # they try to share a file.
      apps.core.shareapi_only_share_with_group_members = "yes";
      apps.registration.admin_approval_required = "yes";
      # Default quota for new users
      apps.files.default_quota = "40GB";
      apps.richdocuments.wopi_url = "https://office.andrewjackson.dev";
      # This is to disable the rich workspace feature because of this issue:
      # https://help.nextcloud.com/t/loading-spinner-in-files-overview/80393
      apps.text.workspace_available = "0";
    };
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
        "/var/lib/mysql"
        "/var/lib/nextcloud"
        "/var/lib/prometheus2"
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

  sops.secrets.tailscale_authkey = {
    sopsFile = ./secrets/common.yaml;
  };

  containers = {
    tsdns =
      let
        authKey = config.sops.secrets.tailscale_authkey.path;
      in
      {
        bindMounts = {
          "${authKey}".isReadOnly = true;
          "/var/lib/tailscale" = {
            hostPath = "/persist/containers/tsdns/tailscale";
            isReadOnly = false;
          };
        };
        autoStart = true;
        ephemeral = true;
        enableTun = true;
        privateNetwork = true;
        hostAddress = "10.100.0.1";
        localAddress = "10.100.0.2";
        config = { config, pkgs, lib, ... }: {
          imports = [
            leng.nixosModules.default
          ];

          services = {
            leng = {
              enable = true;
              configuration = {
                customdnsrecords = [
                  "*.ajackson.dev IN A 100.92.22.51"
                  "triton.home IN A 192.168.1.75"
                ];
                blocking.sourcesStore = "/var/lib/leng-sources";
                blocking.sourcedirs = [ "/var/lib/leng-sources/" ];
              };
            };

            tailscale = {
              enable = true;
              # authKeyFile = authKey;
              extraUpFlags = [
                "--accept-dns=false"
              ];
            };
          };

          system.stateVersion = "23.05";

          networking = {
            firewall = {
              enable = true;
            };

            useHostResolvConf = lib.mkForce false;
            nameservers = [ "192.168.1.1" ];
          };
        };
      };
  };
}
