{ config, ... }:
{
  sops.secrets.miniflux = {
    sopsFile = ./secrets.yaml;
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets.miniflux.path;
    config.LISTEN_ADDR = "localhost:${toString config.homelab.ports.miniflux}";
  };
}
