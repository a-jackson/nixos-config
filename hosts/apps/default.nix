{
  abe,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./audiobookshelf.nix
    # ./containers.nix
    ./docker.nix
    ./forgejo.nix
    # ./kodi.nix
    ./miniflux.nix
    ./monitoring.nix
    ./multimedia.nix
    ./nextcloud.nix
    ./nginx.nix
    ./paperless.nix
    ./stirling.nix
    abe.nixosModules.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-wrapped-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-6.0.428"
  ];

  sops.secrets.cloudflare_apikey = {
    sopsFile = ./secrets.yaml;
  };

  networking = {
    interfaces = {
      eno1.ipv4.addresses = [
        {
          address = "192.168.1.205";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "eno1";
    };
    nameservers = [
      "127.0.0.1"
      "192.168.1.75"
    ];

    firewall = {
      allowedTCPPorts = [ 443 ];
    };
  };

  homelab = {
    root = {
      diskLabel = "server";
      ephemeralBtrfs.enable = true;
    };

    restic = {
      daily = {
        paths = [
          "/persist"
          "/data/images"
        ];
      };
    };
    impermanence.enable = true;

    dns = {
      enable = true;
      virtualHosts = {
        target = "192.168.1.205";
      };
    };
  };

  services = {
    mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = config.homelab.ports.mealie;
    };

    frigate = {
      enable = false;
      hostname = "cameras.ajackson.dev";
      settings.cameras = {
        gp_top = {
          ffmpeg.inputs = [
            {
              path = "rtsp://192.168.1.15:8554/unicast";
              roles = [
                "detect"
                "record"
              ];
            }
          ];
          detect.enabled = false;
        };
        kitchen = {
          ffmpeg.inputs = [
            {
              path = "rtsp://camera:shorts-coat-drinking@192.168.1.109:554/stream1";
              roles = [
                "detect"
                "record"
              ];
            }
          ];
          detect.enabled = false;
        };
      };
    };

    silverbullet = {
      enable = true;
      listenPort = config.homelab.ports.silverbullet;
    };
  };

  environment = {
    systemPackages = with pkgs; [ nfs-utils ];
  };

  fileSystems."/data/images" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [
      "subvol=images"
      "compress=zstd"
    ];
  };
  fileSystems."/data/audio" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [
      "subvol=audio"
      "compress=zstd"
    ];
  };

  services.rpcbind.enable = true;
  systemd.mounts =
    let
      nasMount = folder: {
        type = "nfs";
        mountConfig = {
          Options = "noatime,nfsvers=4.2";
        };
        what = "192.168.1.75:/mnt/user/${folder}";
        where = "/mnt/user/${folder}";
      };
    in
    [
      (nasMount "video")
      (nasMount "images")
      (nasMount "audio")
    ];
  systemd.automounts =
    let
      nasMount = folder: {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/mnt/user/${folder}";
      };
    in
    [
      (nasMount "video")
      (nasMount "images")
      (nasMount "audio")
    ];
}
