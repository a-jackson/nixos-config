{ pkgs, config, leng, ... }: {
  imports = [
    leng.nixosModules.default
    ./hardware-configuration.nix
    ../common
    ./containers.nix
    ./docker.nix
    ./leng.nix
    ./multimedia.nix
    ./nextcloud.nix
    ./nginx.nix
  ];

  sops.secrets.cloudflare_apikey = {
    sopsFile = ./secrets.yaml;
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
    };
  };

  rootDiskLabel = "server";

  services = {
    leng = {
      enable = true;
      virtualHosts = {
        target = "192.168.1.205";
        hosts = builtins.attrNames config.services.nginx.virtualHosts;
      };
    };

    restic_backups = {
      daily = {
        paths = [
          "/persist"
        ];
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

    cfdyndns = {
      enable = true;
      records = [
        "requests.andrewjackson.dev"
        "jellyfin.andrewjackson.dev"
      ];
      apiTokenFile = config.sops.secrets.cloudflare_apikey.path;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
  '';

  environment = {
    systemPackages = with pkgs; [
      nfs-utils
    ];

    persistence."/persist" = {
      directories = [
        "/var/lib/prometheus2"
        "/var/lib/private/leng-sources"
      ];
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
      (tritonMount "audio")
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
      (tritonMount "audio")
    ];
}
