{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  rootDiskLabel = "desktop";

  homelab.restic = { daily = { paths = [ "/persist" "/home" ]; }; };
  homelab.homeType = "plasma";
}
