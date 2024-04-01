{ pkgs, ... }:
let
  backupPaths = [ "/persist" "/home" "/mnt/user" ];
  excludePaths = [
    "/mnt/user/audio"
    "/mnt/user/software"
    "/mnt/user/video/films"
    "/mnt/user/video/f1"
    "/mnt/user/video/tv"
  ];
in {
  imports =
    [ ./hardware-configuration.nix ./disks.nix ./networking.nix ./nfs.nix ];

  homelab = {
    root = { ephemeralBtrfs.enable = true; };
    impermanence.enable = true;
    monitoring.enable = true;
    restic = {
      daily = {
        paths = backupPaths;
        exclude = excludePaths;
      };
    };
  };

  fileSystems."/mnt/parity" = {
    device = "/dev/disk/by-label/parity";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

  services = {
    snapraid = {
      enable = true;
      parityFiles = [ "/mnt/parity/snapraid.parity" ];
      dataDisks = {
        disk1 = "/mnt/disks/disk1";
        disk2 = "/mnt/disks/disk2";
        disk3 = "/mnt/disks/disk3";
        disk4 = "/mnt/disks/disk4";
      };
      contentFiles = [
        "/var/lib/snapraid.content"
        "/mnt/disks/disk1/.snapraid.1.content"
        "/mnt/disks/disk2/.snapraid.2.content"
        "/mnt/disks/disk3/.snapraid.3.content"
        "/mnt/disks/disk4/.snapraid.4.content"
      ];
    };
  };

  environment.systemPackages = with pkgs; [ smartmontools ];
}
