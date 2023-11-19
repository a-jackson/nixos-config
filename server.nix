{ pkgs, ... }:
let
  overlay-jellyseer = final: prev: {
    jellyseerr = final.callPackage ./packages/jellyseerr { };
  };
in
{
  imports = [
    ./base.nix
    ./modules/ssh.nix
    ./modules/mergerfs.nix
  ];

  nixpkgs.overlays = [
    overlay-jellyseer
  ];

  services = {
    jellyseerr = {
      enable = true;
      openFirewall = true;
      port = 5055;
    };

    mergerfs = {
      enable = true;
      disks = [
        "/mnt/disks/disk1"
        "/mnt/disks/disk2"
        "/mnt/disks/disk3"
      ];
    };
  };

  fileSystems = {
    "/mnt/disks/disk1" = {
      device = "/dev/disk/by-label/disk1";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
    "/mnt/disks/disk2" = {
      device = "/dev/disk/by-label/disk2";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
    "/mnt/disks/disk3" = {
      device = "/dev/disk/by-label/disk3";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/jellyseerr"
      "/var/lib/sonarr"
      "/var/lib/radarr"
    ];
  };

  systemd.services.init-media-network = {
    description = "Create the network bridge for immich.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
          # Put a true at the end to prevent getting non-zero return code, which will
          # crash the whole service.
          check=$(${pkgs.podman}/bin/podman network ls | grep "media" || true)
          if [ -z "$check" ]; then
            ${pkgs.podman}/bin/podman network create media
          else
               echo "media already exists in podman"
           fi
        '';
  };

  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      volumes = [
        "/var/lib/sonarr:/config"
      ];
      ports = [
        "8989:8989"
      ];
      extraOptions = [
        "--network=media"
      ];
    };
    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      volumes = [
        "/var/lib/radarr:/config"
      ];
      ports = [
        "7878:7878"
      ];
      extraOptions = [
        "--network=media"
      ];
    };
  };
}
