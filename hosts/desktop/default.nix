{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  homelab = {
    root = {
      diskLabel = "desktop";
      ephemeralBtrfs.enable = true;
    };
    impermanence.enable = true;

    restic = { daily = { paths = [ "/persist" "/home" ]; }; };
    homeType = "plasma";
  };
}
