{ config, lib, ... }:
let
  cfg = config.services.leng;
in
{
  options = { };

  config = lib.mkIf cfg.enable {
    services = {
      leng = {
        configuration = {
          customdnsrecords = [
            "*.ajackson.dev IN A 100.92.22.51"
            "triton.home IN A 192.168.1.75"
          ];
          blocking.sourcesStore = "/var/lib/leng-sources";
          blocking.sourcedirs = [ "/var/lib/leng-sources/" ];
        };
      };
    };
  };
}
