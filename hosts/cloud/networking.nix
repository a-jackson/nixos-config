{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    useDHCP = lib.mkForce false;
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = "95.216.200.233";
          prefixLength = 32;
        }];
        ipv6.addresses = [
          {
            address = "2a01:4f9:c011:9f5a::1";
            prefixLength = 64;
          }
          {
            address = "fe80::9400:3ff:fe18:e7cb";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "172.31.1.1";
            prefixLength = 32;
          }
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "172.31.1.1";
          }
        ];
        ipv6.routes = [{
          address = "fe80::1";
          prefixLength = 128;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:03:18:e7:cb", NAME="eth0"

  '';
}
