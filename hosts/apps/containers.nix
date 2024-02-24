{ config, ... }:
let
  hosts = builtins.attrNames config.services.nginx.virtualHosts;
in
{
  networking = {
    firewall = {
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
      '';
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eno1";
    };
  };

  containers = {
    tsdns = {
      bindMounts = {
        "/var/lib/tailscale" = {
          hostPath = "/persist/containers/tsdns/tailscale";
          isReadOnly = false;
        };
      };
      forwardPorts = [{
        containerPort = 3500;
        hostPort = 3501;
        protocol = "tcp";
      }];
      autoStart = true;
      ephemeral = true;
      enableTun = true;
      privateNetwork = true;
      hostAddress = "10.100.0.1";
      localAddress = "10.100.0.2";
      config = { lib, ... }: {
        imports = [
          ./adguardhome.nix
        ];

        services = {
          adguardhome = {
            enable = true;
            virtualHosts = {
              target = "100.92.22.51";
              hosts = hosts;
            };
          };
          tailscale.enable = true;
        };

        system.stateVersion = "23.05";

        networking = {
          firewall = {
            enable = true;
          };

          useHostResolvConf = lib.mkForce false;
          nameservers = [ "192.168.1.1" ];
        };
      };
    };
  };
}
