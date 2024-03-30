{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.adguardhome;
in {
  options = {
    services.adguardhome = {
      virtualHosts.target = mkOption { type = types.str; };
      virtualHosts.hosts = mkOption { type = types.listOf types.str; };
    };
  };

  config = mkIf cfg.enable {
    services = {
      adguardhome = let
        records = builtins.map (host: {
          domain = host;
          answer = cfg.virtualHosts.target;
        }) cfg.virtualHosts.hosts;
      in {
        mutableSettings = false;
        openFirewall = true;
        settings = {
          bind_host = "0.0.0.0";
          bind_port = 3500;
          http = { address = "0.0.0.0:3500"; };
          dns = {
            bind_host = "0.0.0.0";
            bootstrap_dns = [ "9.9.9.9" ];
            rewrites = [
              {
                domain = "nas.home";
                answer = "192.168.1.75";
              }
              {
                domain = "apps.home";
                answer = "192.168.1.205";
              }
              {
                domain = "pisvrapp03.home";
                answer = "192.168.1.203";
              }
            ] ++ records;
          };
        };
      };
    };

    networking = { firewall = { allowedUDPPorts = [ 53 ]; }; };
  };
}
