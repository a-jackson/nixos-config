{ pkgs, ... }:
let
  disk1 = "8111cbf1-c1be-4af1-a745-f523da42c84c";
  disk2 = "86138b71-b9a4-47a1-baf3-32c50362ad12";
  disk3 = "72ed5b8f-bfb9-4397-a40e-cf56cd7961c1";
  disk4 = "8987d621-66bb-46e8-9534-67e96f5b0e58";
in {

  environment.systemPackages = with pkgs; [ mergerfs ];
  fileSystems = let
    diskMount = uuid: {
      device = "/dev/disk/by-uuid/${uuid}";
      fsType = "xfs";
    };
  in {
    "/mnt/disks/disk1" = diskMount disk1;
    "/mnt/disks/disk2" = diskMount disk2;
    "/mnt/disks/disk3" = diskMount disk3;
    "/mnt/disks/disk4" = diskMount disk4;
    "/mnt/user" = {
      fsType = "fuse.mergerfs";
      device = "/mnt/disks/*";
      options =
        [ "cache.files=partial" "dropcacheonclose=true" "category.create=mfs" ];
      depends = [
        "/mnt/disks/disk1"
        "/mnt/disks/disk2"
        "/mnt/disks/disk3"
        "/mnt/disks/disk4"
      ];
    };
    # "/mnt/parity" = diskMount "parity";
  };
}
