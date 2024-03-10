{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [ mergerfs ];
  fileSystems = let
    diskMount = label: {
      device = "/dev/disk/by-label/${label}";
      fsType = "xfs";
      options = [ ];
    };
  in {
    "/mnt/disks/disk1" = diskMount "disk1";
    "/mnt/disks/disk2" = diskMount "disk2";
    "/mnt/disks/disk3" = diskMount "disk3";
    "/mnt/disks/disk4" = diskMount "disk4";
    "/mnt/user" = {
      fsType = "fuse.mergerfs";
      device = "/mnt/disks/*";
      options =
        [ "cache.files=partial" "dropcacheonclose=true" "category.create=mfs" ];
    };
    # "/mnt/parity" = diskMount "parity";
  };
}
