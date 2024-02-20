job "jaeger-agent" {
  datacenters = ["aws-eu-north-1"]
  type = "system"

  group "jaeger-agent" {
    network {
      mode = "bridge"
      port "thrift_compact" {
        static = 6831
      }
      port "thrift_binary" {
        static = 6832
      }
      port "sampling" {
        static = 5778
      }
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }

    }

    service {
      name = "jaeger-agent"
      port = "14271"

      check {
        expose   = true
        type     = "http"
        path     = "/"
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
                local_path_port = 14721
                listener_port   = "metrics"
              }
            }
            upstreams {
              destination_name = "tempo-jaeger-collector-grpc"
              local_bind_port  = 9090
            }
          }
        }
      }
    }

    task "jaeger-agent" {
      driver = "docker"
      config {
        image = "jaegertracing/jaeger-agent:1.27.0"
        ports = ["thrift_compact", "thrift_binary", "sampling"]
      }

      resources {
        cpu = 100
        memory = 64
      }

      env {
        REPORTER_GRPC_HOST_PORT = "${NOMAD_UPSTREAM_ADDR_tempo-jaeger-collector-grpc}"
      }
    }
  }
}