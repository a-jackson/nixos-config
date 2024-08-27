{ config, pkgs, ... }:
{
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = config.homelab.ports.stirling-pdf;
    };
  };

  systemd.services.stirling-pdf.path = with pkgs; [ ghostscript_headless ];
}
