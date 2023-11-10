{ ... }:
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
    ];
  };
}
