{
  nixpkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.luks.devices."kerberos".device = "/dev/disk/by-uuid/16e6be9a-5ef2-437a-b9fc-b7867c9cb09d";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 4096;
    }
  ];

  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = nixpkgs.lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = nixpkgs.lib.mkDefault config.hardware.enableRedistributableFirmware;
}
