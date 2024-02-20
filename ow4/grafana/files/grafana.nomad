job "grafana" {
  region      = "global"
  datacenters = ["aws-eu-north-1"]
  type        = "service"

  group "grafana" {
    vault {
      policies    = ["grafana"]
      change_mode = "noop"
    }

    network {
      mode = "bridge"
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }

      dns {
        servers = ["169.254.169.253", "8.8.8.8"]
      }
    }

    service {
      name = "grafana"
      port = "3000"
      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
        metrics_path = "/metrics"
      }
      check {
        expose   = true
        type     = "http"
        path     = "/api/health"
        interval = "10s"
        timeout  = "2s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.grafana.rule=Host(`grafana.online.ntnu.no`)",
        "traefik.http.routers.grafana.middlewares=default-basicauth@consul",
      ]

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
            upstreams {
              destination_name = "prometheus"
              local_bind_port  = 9090
            }
            upstreams {
              destination_name = "loki"
              local_bind_port  = 3100
            }
            upstreams {
              destination_name = "alertmanager"
              local_bind_port  = 9093
            }
            upstreams {
              destination_name = "tempo"
              local_bind_port  = 3200
            }
          }
        }
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:8.1.2"
        volumes = [
          "secrets/grafana.ini:/etc/grafana/grafana.ini",
          "local/provisioning:/etc/grafana/provisioning",
        ]
      }

      resources {
        cpu    = 200
        memory = 512
      }

      template {
        destination = "secrets/file.env"
        change_mode = "restart"
        env = true
        data = <<-EOF
          {{ with secret "aws/creds/grafana" }}
          AWS_ACCESS_KEY_ID="{{ .Data.access_key }}"
          AWS_SECRET_ACCESS_KEY="{{ .Data.secret_key }}"
          {{ end }}
        EOF
      }

      template {
        destination = "secrets/grafana.ini"
        change_mode = "restart"
        data = <<-EOH
          [server]
          domain = grafana.online.ntnu.no

          {{ with secret "postgres/static-creds/grafana" }}
          [database]
          type = postgres
          user = grafana
          password = {{ .Data.password }}
          name = grafana
          host = main-db.cxliesrki50e.eu-north-1.rds.amazonaws.com:5432
          {{ end }}
        EOH
      }

      template {
        destination = "local/provisioning/datasources/datasources.yml"
        change_mode = "restart"
        data = <<-EOH
          apiVersion: 1

          datasources:
            - name: Prometheus
              type: prometheus
              url: http://{{ env "NOMAD_UPSTREAM_ADDR_prometheus" }}
              access: proxy
              isDefault: true
              editable: true

            - name: Loki
              type: loki
              url: http://{{ env "NOMAD_UPSTREAM_ADDR_loki" }}
              access: proxy
              editable: true
              jsonData:
                maxLines: 1000
                derivedFields:
                  - datasourceUid: tempo
                    matcherRegex: >
                      request_Uber-Trace-Id":"([^:]*)
                    name: TraceID
                    url: "$${__value.raw}"

            - name: Tempo
              type: tempo
              uid: tempo
              url: http://{{ env "NOMAD_UPSTREAM_ADDR_tempo" }}
              access: proxy
              editable: true

            - name: CloudWatch
              type: cloudwatch
              editable: true
              jsonData:
                defaultRegion: 'eu-north-1'
          EOH
      }
    }
  }
}
