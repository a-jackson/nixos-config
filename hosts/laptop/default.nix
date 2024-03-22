{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ../common ../common/de.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  rootDiskLabel = "kerberos";

  homelab.restic = { daily = { paths = [ "/persist" "/home" ]; }; };

  virtualisation.docker.enable = true;
  users.users.andrew.extraGroups = [ "docker" ];

  environment = { systemPackages = with pkgs; [ docker-compose ]; };
}
