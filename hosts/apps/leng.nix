{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.leng;
in
{
  options = { 
    services.leng = {
      virtualHosts.target = mkOption {
        type = types.str;
      };
      virtualHosts.hosts = mkOption {
        type = types.listOf types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      leng =
        let
          records = builtins.map (host: host + " IN A " + cfg.virtualHosts.target) cfg.virtualHosts.hosts;
        in
        {
          configuration = {
            customdnsrecords = [
              "triton.home IN A 192.168.1.75"
            ] ++ records;
            blocking.sourcesStore = "/var/lib/leng-sources";
            blocking.sourcedirs = [ "/var/lib/leng-sources/" ];
          };
        };
    };
  };
}
