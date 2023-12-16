{ pkgs, ... }:
let
  overlay-jellyseer = final: prev: {
    jellyseerr = final.callPackage ./packages/jellyseerr { };
  };
in
{
  imports = [
    ./base.nix
    ./modules/ssh.nix
  ];

  networking = {
  interfaces = {
    enp1s0.ipv4.addresses = [{
      address = "192.168.1.205";
      prefixLength = 24;
    }];
  };
  defaultGateway = {
    address = "192.168.1.1";
    interface = "enp1s0";
  };
};

  rootDiskLabel = "server";

  nixpkgs.overlays = [
    overlay-jellyseer
  ];

  services = {
    jellyseerr = {
      enable = true;
      openFirewall = true;
      port = 5055;
    };

    sonarr = {
      enable=true;
    };

    radarr = {
      enable=true;
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/jellyseerr"
      "/var/lib/sonarr"
      "/var/lib/radarr"
    ];
  };
}
