{ pkgs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common
    ./adguardhome.nix
    ./containers.nix
    ./docker.nix
    ./monitoring.nix
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
    nameservers = [
      "127.0.0.1"
    ];

    firewall = {
      allowedTCPPorts = [ 443 ];
    };
  };

  rootDiskLabel = "server";

  services = {
    adguardhome = {
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

    cfdyndns = {
      enable = true;
      records = [
        "requests.andrewjackson.dev"
        "jellyfin.andrewjackson.dev"
      ];
      apiTokenFile = config.sops.secrets.cloudflare_apikey.path;
    };
  };

  virtualisation.oci-containers.containers = {
    # sudo docker run -it -p 3000:3000 -v ./space:/space zefhemel/silverbullet
    silverbullet = {
      image = "zefhemel/silverbullet";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "zefhemel/silverbullet";
        imageDigest = "sha256:8926cee41083c860f03f54c3103a92e6b0d81b16dc49f71ecaeb917c555667f5";
        sha256 = "sha256-HnREbkt+rmz1D04UeU66X1pipv2GXOptQ/l1HoBsLDE=";
      };
      ports = [
        "3001:3000"
      ];
      volumes = [
        "silverbullet:/space"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nfs-utils
    ];
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
