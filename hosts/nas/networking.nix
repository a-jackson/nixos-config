{ ... }:
let
  interface = "eno1";
  address = "192.168.1.75";
  defaultGateway = "192.168.1.1";
  nameservers = [ "192.168.1.205" ];
in {
  networking = {
    inherit nameservers;
    interfaces."${interface}".ipv4.addresses = [{
      inherit address;
      prefixLength = 24;
    }];
    defaultGateway = {
      inherit interface;
      address = defaultGateway;
    };
  };
}
