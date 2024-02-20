job "tempo" {
  region      = "global"
  datacenters = ["aws-eu-north-1"]
  type        = "service"


  vault {
    policies    = ["tempo"]
    change_mode = "noop"
  }

  group "tempo" {

    network {
      mode = "bridge"
      port "metrics" {}
      port "health" {}
      port "envoy_metrics" { to = 9102 }
    }

    service {
      name = "tempo"
      port = "3200"

      check {
        expose   = true
        type     = "http"
        path     = "/ready"
        interval = "10s"
        timeout  = "2s"
      }

      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
        metrics_path = "/metrics"
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
                local_path_port = 3200
                listener_port   = "metrics"
              }
            }
          }
        }
      }
    }

    service {
      name = "tempo-jaeger-collector-grpc"
      port = "14250"

      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
      }

      check {
        type     = "http"
        port     = "health"
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
                path            = "/ready"
                protocol        = "http"
                local_path_port = 3200
                listener_port   = "health"
              }
            }
          }
        }
      }
    }

    task "tempo" {
      driver = "docker"

      config {
        image   = "grafana/tempo:1.0.1"
        volumes = ["local/tempo-config.yml:/etc/tempo/tempo-config.yml"]
        args    = ["-config.file=/etc/tempo/tempo-config.yml"]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        destination = "local/tempo-config.yml"
        data = <<-EOH
          server:
            http_listen_port: 3200

          distributor:
            receivers:
                jaeger:
                    protocols:
                        grpc:
                          endpoint: 0.0.0.0:14250

          ingester:
            trace_idle_period: 10s
            max_block_bytes: 1_000_000
            max_block_duration: 5m 

          compactor:
            compaction:
              compaction_window: 1h
              max_block_bytes: 100_000_000
              block_retention: 1h
              compacted_block_retention: 10m

          storage:
            trace:
              backend: s3
              s3:
                endpoint: s3.eu-north-1.amazonaws.com
                bucket: tempo.dotkom
                region: eu-north-1
                access_key: "{{ with secret "aws/creds/tempo" }}{{ .Data.access_key }}{{ end }}"
                secret_key: "{{ with secret "aws/creds/tempo" }}{{ .Data.secret_key }}{{ end }}"

              block:
                bloom_filter_false_positive: .05
                index_downsample_bytes: 1000 
                encoding: zstd
              wal:
                path: /tmp/tempo/wal
                encoding: none
              pool:
                max_workers: 100
                queue_depth: 10000

        EOH
      }
    }
  }
}
