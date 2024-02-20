job "alertmanager" {
  datacenters = ["aws-eu-north-1"]
  type = "service"

  group "alertmanager" {
    count = 1

    network {
      mode = "bridge"
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }
    }

    service {
        name = "alertmanager"
        port = 9093
        tags = [
          "traefik.enable=true",
          "traefik.consulcatalog.connect=true",
          "traefik.http.routers.alertmanager.rule=Host(`alertmanager.online.ntnu.no`)",
          "traefik.http.routers.alertmanager.middlewares=default-basicauth@consul"
        ]

        meta {
          envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
        }

        check {
          expose   = true
          name     = "alertmanager_ui port alive"
          type     = "http"
          path     = "/-/healthy"
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
                  local_path_port = 3000
                  listener_port   = "metrics"
                }
              }
            }
          }
        }
      }

    task "alertmanager" {
      driver = "docker"
      config {
        image = "prom/alertmanager:latest"
      }
      resources {
        cpu = 100
        memory = 128
      }
    }
  }
}