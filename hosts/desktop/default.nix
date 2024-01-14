{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../common/de.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  rootDiskLabel = "desktop";

  services = {
    restic_backups = {
      daily = {
        paths = [
          "/persist"
          "/home"
        ];
      };
    };
  };
}
