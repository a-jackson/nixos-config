{ config, ... }: {
  homelab.monitoring.enable = true;

  services.prometheus = {
    enable = true;

    scrapeConfigs = [{
      job_name = "apps";
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
          "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
        ];
      }];
    }];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.ajackson.dev";
      };
    };
  };
}
