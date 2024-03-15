{ config, ... }: {
  homelab.monitoring.enable = true;

  services = {
    prometheus = {
      enable = true;

      scrapeConfigs = let
        exporters = config.services.prometheus.exporters;
        smartctl_port = toString exporters.smartctl.port;
        node_port = toString exporters.node.port;

        target = name: host: {
          job_name = name;
          static_configs = [{
            targets = [ "${host}:${smartctl_port}" "${host}:${node_port}" ];
          }];
        };
      in [ (target "apps" "127.0.0.1") (target "cloud" "cloud") ];
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "grafana.ajackson.dev";
        };
      };
    };

    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = 3100;

        ingester = {
          lifecycler = {
            address = "0.0.0.0";
            ring.kvstore.store = "inmemory";
            ring.replication_factor = 1;
            final_sleep = "0s";
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 1048576;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config.configs = [{
          from = "2020-10-24";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index.prefix = "index_";
          index.period = "24h";
        }];

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          shared_store = "filesystem";
        };

        storage_config.boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
          shared_store = "filesystem";
        };
        storage_config.filesystem = { directory = "/var/lib/loki/chunks"; };

        limits_config.reject_old_samples = true;
        limits_config.reject_old_samples_max_age = "168h";

        chunk_store_config.max_look_back_period = "0s";

        table_manager.retention_deletes_enabled = false;
        table_manager.retention_period = "0s";
      };
    };
  };
}
