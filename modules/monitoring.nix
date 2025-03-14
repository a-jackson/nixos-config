{ config, lib, ... }:
with lib;
let
  cfg = config.homelab.monitoring;
  ports = config.homelab.ports;
in
{
  options.homelab.monitoring = {
    enable = mkEnableOption "Enable monitoring";
    smartctl.enable = mkOption {
      type = types.bool;
      description = "Enable smartctl";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters = {
      smartctl = {
        enable = cfg.smartctl.enable;
        openFirewall = true;
        port = ports.smartctl;
      };

      node = {
        enable = true;
        openFirewall = true;
        enabledCollectors = [ "systemd" ];
        port = ports.node;
      };
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
    '';

    services.promtail = {
      enable = true;
      configuration = {
        server.http_listen_port = ports.promtail;
        server.grpc_listen_port = 0;
        positions.filename = "/tmp/positions.yml";
        clients = [ { url = "http://apps:3100/loki/api/v1/push"; } ];
        scrape_configs =
          [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels.job = "systemd-journal";
                labels.host = config.networking.hostName;
              };
              relabel_configs = [
                {
                  source_labels = [ "__journal__systemd_unit" ];
                  target_label = "unit";
                }
                {
                  source_labels = [ "__journal_container_name" ];
                  target_label = "container_name";
                }
              ];
            }
          ]
          ++ lib.optional config.services.nginx.enable {
            job_name = "nginx";
            static_configs = [
              {
                targets = [ "localhost" ];
                labels.job = "nginx";
                labels.__path__ = "/var/log/nginx/*.log";
              }
            ];
          };
      };
    };
  };
}
