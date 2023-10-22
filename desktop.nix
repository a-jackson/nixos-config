{ ... }:
{
  imports = [
    ./base.nix
    ./de.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

}
