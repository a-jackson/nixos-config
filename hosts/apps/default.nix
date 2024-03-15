{ abe, pkgs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common
    ./adguardhome.nix
    ./audiobookshelf.nix
    ./containers.nix
    ./docker.nix
    ./forgejo.nix
    ./monitoring.nix
    ./multimedia.nix
    ./nextcloud.nix
    ./nginx.nix
    ./paperless.nix
    abe.nixosModules.default
  ];

  sops.secrets.cloudflare_apikey = { sopsFile = ./secrets.yaml; };

  nixpkgs.overlays = [
    (final: prev: {
      frigate = prev.frigate.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [
          ./patches/frigate/0001-fix-config-check-read-access-to-run-secrets.patch
        ];
      });
    })
  ];

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
    nameservers = [ "127.0.0.1" ];

    firewall = { allowedTCPPorts = [ 443 ]; };
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

    restic_backups = { daily = { paths = [ "/persist" "/data/images" ]; }; };

    frigate = {
      enable = true;
      hostname = "cameras.ajackson.dev";
      settings.cameras = {
        gp_top = {
          ffmpeg.inputs = [{
            path = "rtsp://192.168.1.15:8554/unicast";
            roles = [ "detect" "record" ];
          }];
          detect.enabled = false;
        };
      };
    };
  };

  virtualisation.oci-containers.containers =
    let images = builtins.fromJSON (builtins.readFile ../../images.json);
    in {
      silverbullet = {
        image = images.silverbullet.image;
        imageFile = pkgs.dockerTools.pullImage {
          imageName = images.silverbullet.image;
          imageDigest = images.silverbullet.imageDigest;
          sha256 = images.silverbullet.sha256;
        };
        ports = [ "3001:3000" ];
        volumes = [ "silverbullet:/space" ];
      };
    };

  environment = { systemPackages = with pkgs; [ nfs-utils ]; };

  fileSystems."/data/images" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "subvol=images" "compress=zstd" ];
  };
  fileSystems."/data/audio" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "subvol=audio" "compress=zstd" ];
  };

  services.rpcbind.enable = true;
  systemd.mounts = let
    tritonMount = folder: {
      type = "nfs";
      mountConfig = { Options = "noatime"; };
      what = "192.168.1.75:/mnt/user/${folder}";
      where = "/mnt/user/${folder}";
    };
  in [
    (tritonMount "video")
    (tritonMount "images")
    (tritonMount "appdata")
    (tritonMount "audio")
  ];
  systemd.automounts = let
    tritonMount = folder: {
      wantedBy = [ "multi-user.target" ];
      automountConfig = { TimeoutIdleSec = "600"; };
      where = "/mnt/user/${folder}";
    };
  in [
    (tritonMount "video")
    (tritonMount "images")
    (tritonMount "appdata")
    (tritonMount "audio")
  ];
}
