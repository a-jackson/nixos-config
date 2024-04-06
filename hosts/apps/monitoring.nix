{ config, ... }:
{
  homelab.monitoring.enable = true;

  services = {
    prometheus = {
      enable = true;
      port = config.homelab.ports.prometheus;

      scrapeConfigs =
        let
          smartctlPort = toString config.homelab.ports.smartctl;
          nodePort = toString config.homelab.ports.node;

          target = name: host: {
            job_name = name;
            static_configs = [
              {
                targets = [
                  "${host}:${smartctlPort}"
                  "${host}:${nodePort}"
                ];
                labels = {
                  host = name;
                };
              }
            ];
          };
        in
        [
          (target "apps" "127.0.0.1")
          (target "cloud" "cloud")
          (target "nas" "nas")
          {
            job_name = "immich";
            static_configs = [
              {
                targets = [
                  "127.0.0.1:8081"
                  "127.0.0.1:8083"
                ];
              }
            ];
          }
        ];
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = config.homelab.ports.grafana;
          domain = "grafana.ajackson.dev";
          root_url = "https://grafana.ajackson.dev";
        };
      };
    };

    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = config.homelab.ports.loki;

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

        schema_config.configs = [
          {
            from = "2020-10-24";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index.prefix = "index_";
            index.period = "24h";
          }
        ];

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
        storage_config.filesystem = {
          directory = "/var/lib/loki/chunks";
        };

        # ruler = {
        #   storage = {
        #     type = "local";
        #     local.directory = "/tmp/rules";
        #   };
        #   rule_path = "/tmp/scratch";
        #   alertmanager_url = "http://localhost";
        #   ring.kvstore.store = "inmemory";
        #   enable_api = true;
        # };

        limits_config.reject_old_samples = true;
        limits_config.reject_old_samples_max_age = "168h";

        chunk_store_config.max_look_back_period = "0s";

        table_manager.retention_deletes_enabled = false;
        table_manager.retention_period = "0s";
      };
    };
  };
}
