job "prometheus" {
  datacenters = ["aws-eu-north-1"]
  type        = "service"

  vault {
    policies    = ["prometheus"]
    change_mode = "noop"
  }

  group "prometheus" {
    count = 1

    volume "storage" {
			type      = "csi"
			read_only = false
			source    = "prometheus"
			attachment_mode = "file-system"
			access_mode = "multi-node-multi-writer"
		}

    network {
      mode = "bridge"
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }
    }

    service {
      name = "prometheus"
      port = "9090"

      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
        metrics_path = "/metrics"
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
      }

      check {
        expose   = true
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }

      tags = [
        "traefik.enable=true",
				"traefik.consulcatalog.connect=true",
        "traefik.http.routers.prometheus.rule=Host(`prometheus.online.ntnu.no`, `prometheus.service.consul`)",
        "traefik.http.routers.prometheus.middlewares=default-basicauth@consul",
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
                local_path_port = 9090
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

    task "prometheus" {
      driver = "docker"

      config {
        image   = "prom/prometheus:v2.29.1"
        volumes = ["secrets/:/etc/prometheus/"]
        args = [
          "--config.file", "/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path", "/opt/prometheus"
        ]
      }

      volume_mount {
				volume      = "storage"
				destination = "/opt/prometheus"
				read_only   = false
			}

      env {
        CONSUL_HTTP_ADDR = "${attr.driver.docker.bridge_ip}:8500"
      }

      resources {
        cpu    = 512
        memory = 2048
      }

      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "secrets/prometheus.yml"

        data = <<-EOF
          global:
            scrape_interval:     5s
            evaluation_interval: 5s


          alerting:
            alertmanagers:
            - static_configs:
              - targets: ['{{ env "NOMAD_UPSTREAM_ADDR_alertmanager" }}']

          scrape_configs:
            - job_name: node-metrics
              static_configs:
              - targets: [{{ range nodes }}'{{- .Address -}}:9100',{{ end }}]

            - job_name: promtail
              static_configs:
              - targets: [{{ range nodes }}'{{- .Address -}}:9080',{{ end }}]

            - job_name: 'vault-metrics'
              metrics_path: "/v1/sys/metrics"
              params:
                format: ['prometheus']
              scheme: https
              bearer_token: "{{ env "VAULT_TOKEN" }}"
              static_configs:
              - targets: ['vault.online.ntnu.no:8200']

            - job_name: 'nomad-metrics'
              scheme: https
              consul_sd_configs:
              - server: '{{ env "CONSUL_HTTP_ADDR" }}'
                services: ['nomad-client', 'nomad']

              relabel_configs:
              - source_labels: ['__meta_consul_tags']
                regex: '(.*)http(.*)'
                action: keep

              scrape_interval: 5s
              metrics_path: /v1/metrics
              params:
                format: ['prometheus']

              tls_config:
                ca_file: /etc/prometheus/nomad-ca.crt
                cert_file: /etc/prometheus/nomad.crt
                key_file: /etc/prometheus/nomad.key
                insecure_skip_verify: true

            - job_name: 'consul-metrics'
              scheme: https
              consul_sd_configs:
              - server: '{{ env "CONSUL_HTTP_ADDR" }}'
                services: ['consul']

              relabel_configs:
              - source_labels: ['__meta_consul_address']
                target_label: '__address__'
                replacement: '$1:8501'

              scrape_interval: 5s
              metrics_path: /v1/agent/metrics
              params:
                format: ['prometheus']

              tls_config:
                ca_file: /etc/prometheus/consul-ca.crt
                cert_file: /etc/prometheus/consul.crt
                key_file: /etc/prometheus/consul.key
                insecure_skip_verify: true

            - job_name: consul-services
              consul_sd_configs:
              - server: '{{ env "CONSUL_HTTP_ADDR" }}'
              relabel_configs:
                - source_labels: [__meta_consul_service]
                  action: drop
                  regex: (.+)-sidecar-proxy
                - source_labels: [__meta_consul_service]
                  target_label: job
                - source_labels: [__meta_consul_service_metadata_metrics_path]
                  action: keep
                  regex: (.+)
                - source_labels: [__meta_consul_service_metadata_metrics_path]
                  target_label: __metrics_path__
                  regex: (.+)
                - source_labels: [__meta_consul_address, __meta_consul_service_metadata_metrics_port]
                  separator: ":"
                  target_label: __address__

            - job_name: consul-connect-envoy
              consul_sd_configs:
              - server: '{{ env "CONSUL_HTTP_ADDR" }}'
              relabel_configs:
                - source_labels: [__meta_consul_service]
                  action: drop
                  regex: (.+)-sidecar-proxy
                - source_labels: [__meta_consul_service_metadata_envoy_metrics_port]
                  action: keep
                  regex: (.+)
                - source_labels: [__meta_consul_address, __meta_consul_service_metadata_envoy_metrics_port]
                  separator: ":"
                  target_label: __address__

          {{ range $i := loop 1 5 }}
            - job_name: onlineweb4-worker-{{ $i }}
              consul_sd_configs:
              - server: '{{ env "CONSUL_HTTP_ADDR" }}'
                services: ['onlineweb4']
              relabel_configs:
                - target_label: job
                  replacement: onlineweb4
                - target_label: gunicorn_worker
                  replacement: {{ $i }}
                - source_labels: [__meta_consul_service_metadata_metrics_path]
                  action: keep
                  regex: (.+)
                - source_labels: [__meta_consul_service_metadata_metrics_path]
                  target_label: __metrics_path__
                  regex: (.+)
                - source_labels: [__meta_consul_service_metadata_metrics_port_{{ $i }}]
                  target_label: port
                - source_labels: [__meta_consul_address, port]
                  separator: ":"
                  target_label: __address__
          {{ end }}
        EOF
      }

      template {
        destination   = "secrets/consul.crt"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<-EOF
          {{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.certificate -}}
          {{- end -}}
        EOF
      }

      template {
        destination   = "secrets/consul.key"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<-EOF
          {{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.private_key -}}
          {{- end -}}
        EOF
      }

      template {
        destination   = "secrets/consul-ca.crt"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<EOF
          {{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.issuing_ca -}}
          {{- end -}}
        EOF
      }

      template {
        destination   = "secrets/nomad.crt"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<EOF
          {{- with secret "pki_int/issue/nomad-client" "common_name=client.global.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.certificate -}}
          {{- end -}}
        EOF
      }

      template {
        destination   = "secrets/nomad.key"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<EOF
          {{- with secret "pki_int/issue/nomad-client" "common_name=client.global.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.private_key -}}
          {{- end }}
        EOF
      }

      template {
        destination   = "secrets/nomad-ca.crt"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<EOF
          {{- with secret "pki_int/issue/nomad-client" "common_name=client.global.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
          {{- .Data.issuing_ca -}}
          {{- end -}}
        EOF
      }
    }
    task "prep-volume" {
			driver = "docker"
			config {
				image = "prom/prometheus:v2.29.1"
				entrypoint = ["chown"]
				args = ["-R", "nobody:nobody", "/opt/prometheus"]
			}
			user = "root"
			volume_mount {
				volume      = "storage"
				destination = "/opt/prometheus"
				read_only   = false
			}
			lifecycle {
				hook = "prestart"
				sidecar = false
			}
		}
  }
}
