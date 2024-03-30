{ lib, config, ... }:
let
  cfg = config.homelab.root;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/disk/by-label/${cfg.diskLabel} "$MNTPOINT"
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
in {
  options.homelab.root = {
    diskLabel = mkOption {
      type = types.str;
      default = config.networking.hostName;
    };
    ephemeralBtrfs.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.ephemeralBtrfs.enable {
    boot.initrd = {
      supportedFilesystems = [ "btrfs" ];
      postDeviceCommands = lib.mkIf (!phase1Systemd) (lib.mkBefore wipeScript);
      systemd.services.restore-root = lib.mkIf phase1Systemd {
        description = "Rollback btrfs rootfs";
        wantedBy = [ "initrd.target" ];
        requires = [ "dev-disk-by\\x2dlabel-${cfg.diskLabel}.device" ];
        after = [
          "dev-disk-by\\x2dlabel-${cfg.diskLabel}.device"
          "systemd-cryptsetup@${cfg.diskLabel}.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = wipeScript;
      };
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/${cfg.diskLabel}";
        fsType = "btrfs";
        options = [ "subvol=root" "compress=zstd" ];
        neededForBoot = true;
      };

      "/home" = {
        device = "/dev/disk/by-label/${cfg.diskLabel}";
        fsType = "btrfs";
        options = [ "subvol=home" "compress=zstd" ];
      };

      "/nix" = {
        device = "/dev/disk/by-label/${cfg.diskLabel}";
        fsType = "btrfs";
        options = [ "subvol=nix" "noatime" "compress=zstd" ];
      };

      "/persist" = {
        device = "/dev/disk/by-label/${cfg.diskLabel}";
        fsType = "btrfs";
        options = [ "subvol=persist" "compress=zstd" ];
        neededForBoot = true;
      };

      "/swap" = {
        device = "/dev/disk/by-label/${cfg.diskLabel}";
        fsType = "btrfs";
        options = [ "subvol=swap" "noatime" ];
      };
    };
  };
}
