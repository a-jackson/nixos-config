{ config, ... }:
{
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = config.homelab.ports.stirling-pdf;
    };
  };
}
