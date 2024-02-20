job "loki" {
  region      = "global"
  datacenters = ["aws-eu-north-1"]
  type        = "service"

  vault {
    policies    = ["loki"]
    change_mode = "noop"
  }

  group "ingress" {
    network {
      mode = "bridge"
      port "inbound" { 
        static = 3100
        to = 3100
      }
    }

    service {
      name = "loki-ingress"
      port = "3100"

      connect {
        sidecar_task {
          resources {
            cpu    = 128
            memory = 128
          }
        }
        gateway {
          proxy{
          }
          ingress {
            tls {
              enabled = true
            }
            listener {
              port = 3100
              protocol = "http"
              service {
                name = "loki"
                hosts = ["loki.ingress.consul"]
              }
            }
          }
        }
      }
    }
  }

  group "loki" {
    network {
      mode = "bridge"
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }
    }

    service {
      name = "loki"
      port = "3100"
      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
        metrics_path = "/metrics"
      }

      check {
        expose   = true
        type     = "http"
        path     = "/ready"
        interval = "10s"
        timeout  = "2s"
      }
      connect {
        sidecar_task {
          resources {
            cpu    = 128
            memory = 128
          }
        }
        sidecar_service {
          proxy {
           expose {
              path {
                path            = "/metrics"
                protocol        = "http"
                local_path_port = 3100
                listener_port   = "metrics"
              }
            }
            upstreams {
              destination_name = "alertmanager"
              local_bind_port  = 9093
            }
          }
        }
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image   = "grafana/loki:2.4.1"
        volumes = ["local/loki-config.yml:/etc/loki/loki-config.yml"]
        args    = ["-config.file=/etc/loki/loki-config.yml"]
      }

      resources {
        cpu = 256
        memory = 512
      }

      template {
        destination = "local/loki-config.yml"
        data        = <<-EOH
          server:
            http_listen_port: 3100

          auth_enabled: false

          ingester:
            wal:
              enabled: true
              dir: /tmp/wal
            lifecycler:
              address: 0.0.0.0
              ring:
                kvstore:
                  store: inmemory
                replication_factor: 1
              final_sleep: 0s
            chunk_idle_period: 1h
            max_chunk_age: 1h
            chunk_target_size: 1048576
            chunk_retain_period: 30s
            max_transfer_retries: 0

          schema_config:
            configs:
              - from: 2021-11-09
                store: boltdb-shipper
                object_store: s3
                schema: v11
                index:
                  prefix: index_
                  period: 24h

          storage_config:
            boltdb_shipper:
              active_index_directory: /loki/index
              shared_store: s3
              cache_location: /loki/boltdb-cache
            aws:
              bucketnames: "loki.dotkom"
              region: eu-north-1
              access_key_id: "{{ with secret "aws/creds/loki" }}{{ .Data.access_key }}{{ end }}"
              secret_access_key: "{{ with secret "aws/creds/loki" }}{{ .Data.secret_key }}{{ end }}"

          compactor:
            working_directory: /loki/compactor
            shared_store: s3

          limits_config:
            reject_old_samples: true
            reject_old_samples_max_age: 168h

          chunk_store_config:
            max_look_back_period: 0s

          table_manager:
            retention_deletes_enabled: false
            retention_period: 0s

          ruler:
            alertmanager_url: http://{{ env "NOMAD_UPSTREAM_ADDR_alertmanager" }}
            ring:
              kvstore:
                store: inmemory
            enable_api: true
          EOH
      }

    }
  }
}
