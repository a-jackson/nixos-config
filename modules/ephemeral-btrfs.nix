{ lib, config, ... }:
let

  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/disk/by-label/${config.rootDiskLabel} "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Creating needed directories"
      mkdir -p "$MNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/root"

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;

  inherit (lib) mkOption types;
in
{
  options.rootDiskLabel = mkOption {
    type = types.str;
    default = config.networking.hostName;
  };

  config = {
    boot.initrd = {
      supportedFilesystems = [ "btrfs" ];
      postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
      systemd.services.restore-root = lib.mkIf phase1Systemd {
        description = "Rollback btrfs rootfs";
        wantedBy = [ "initrd.target" ];
        requires = [
          "dev-disk-by\\x2dlabel-${config.rootDiskLabel}.device"
        ];
        after = [
          "dev-disk-by\\x2dlabel-${config.rootDiskLabel}.device"
          "systemd-cryptsetup@${config.rootDiskLabel}.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = wipeScript;
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/${config.rootDiskLabel}";
        fsType = "btrfs";
        options = [ "subvol=root" "compress=zstd" ];
        neededForBoot = true;
      };

      "/home" = {
        device = "/dev/disk/by-label/${config.rootDiskLabel}";
        fsType = "btrfs";
        options = [ "subvol=home" "compress=zstd" ];
      };

      "/nix" = {
        device = "/dev/disk/by-label/${config.rootDiskLabel}";
        fsType = "btrfs";
        options = [ "subvol=nix" "noatime" "compress=zstd" ];
      };

      "/persist" = {
        device = "/dev/disk/by-label/${config.rootDiskLabel}";
        fsType = "btrfs";
        options = [ "subvol=persist" "compress=zstd" ];
        neededForBoot = true;
      };

      "/swap" = {
        device = "/dev/disk/by-label/${config.rootDiskLabel}";
        fsType = "btrfs";
        options = [ "subvol=swap" "noatime" ];
      };
    };
  };
}
