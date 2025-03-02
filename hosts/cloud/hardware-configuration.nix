{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    configurationLimit = 3;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D951-0FE6";
    fsType = "vfat";
  };
  fileSystems."/mnt/mail" = {
    device = "/dev/disk/by-label/mail";
    fsType = "btrfs";
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
