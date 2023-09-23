{ nixpkgs, config, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.luks.devices."kerberos".device = "/dev/disk/by-uuid/16e6be9a-5ef2-437a-b9fc-b7867c9cb09d";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems."/" =
    {
      device = "none";
      fsType = "tmpfs";
      neededForBoot = true;
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/C828-8CDB";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    {
      device = "/dev/mapper/kerberos";
      fsType = "btrfs";
      options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=nix" ];
      neededForBoot = true;
    };

  fileSystems."/persist" =
    {
      device = "/dev/mapper/kerberos";
      fsType = "btrfs";
      options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=persist" ];
      neededForBoot = true;
    };

  fileSystems."/etc/nixos" =
    {
      device = "/dev/mapper/kerberos";
      fsType = "btrfs";
      options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=nixos-config" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/mapper/kerberos";
      fsType = "btrfs";
      options = [ "defaults" "compress-force=zstd" "ssd" "subvol=home" ];
    };

  fileSystems."/swap" = {
    device = "/dev/mapper/kerberos";
    fsType = "btrfs";
    options = [ "subvol=swap" "noatime" "compress=lzo" ];
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 4096;
  }];

  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = nixpkgs.lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = nixpkgs.lib.mkDefault config.hardware.enableRedistributableFirmware;
}
