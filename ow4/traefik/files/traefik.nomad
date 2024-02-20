job "traefik" {
  region      = "global"
  datacenters = ["aws-eu-north-1"]
  type        = "system"
  priority = 100

  update {
    auto_revert = true
    max_parallel = 2
  }

  group "traefik" {
    network {
      mode = "bridge"
      port "http_ingress" {
        static = 80
      }
      port "ping" {
        static = 81
      }
      port "metrics" {}
      port "api" {}
    }

    service {
      name = "traefik"
      port = "http_ingress"
      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "traefik-api"
      meta {
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
        metrics_path = "/metrics"
      }
      port = "api"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik.rule=Host(`traefik.online.ntnu.no`)",
        "traefik.http.routers.traefik.middlewares=default-basicauth@consul",
        "traefik.http.routers.traefik.service=api@internal"
      ]

      check {
        type     = "http"
        port     = "ping"
        path     = "/ping"
        interval = "5s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      vault {
        policies    = ["traefik"]
        change_mode = "noop"
      }

      config {
        image = "traefik:latest"
        volumes = [
          "local/traefik.yml:/etc/traefik/traefik.yml",
          "local/.htpasswd:/etc/traefik/.htpasswd",
        ]
        ports = ["api", "http_ingress", "metrics", "ping"]
      }

      env {
        DOCKER_BRIDGE_IP = "${attr.driver.docker.bridge_ip}"
      }

      template {
        destination = "local/traefik.yml"
        data        = <<-EOF
        entryPoints:
          ping:
            address: ":{{ env "NOMAD_PORT_ping" }}"
          http:
            address: ":{{ env "NOMAD_PORT_http_ingress" }}"
          traefik:
            address: ":{{ env "NOMAD_PORT_api" }}"
          metrics:
            address: ":{{ env "NOMAD_PORT_metrics" }}"

        accessLog:
          format: json
          fields:
            defaultMode: keep
            headers:
              defaultMode: drop
              names:
                uber-trace-id: keep
        log:
          format: json
          level: INFO

        api:
          dashboard: true

        ping:
          entryPoint: ping

        metrics:
          prometheus:
            entryPoint: metrics

        tracing:
          jaeger:
            samplingServerURL: http://{{ env "DOCKER_BRIDGE_IP" }}:5778/sampling
            localAgentHostPort: {{ env "DOCKER_BRIDGE_IP" }}:6831

        providers:
          consul:
            endpoints: ["{{ env "DOCKER_BRIDGE_IP" }}:8500"]
          consulCatalog:
            prefix: traefik
            exposedByDefault: false
            connectAware: true
            connectByDefault: false
            endpoint:
              address: {{ env "DOCKER_BRIDGE_IP" }}:8500
              scheme: http
        EOF
      }

      template {
        change_mode = "restart"
        data = <<-EOF
          {{ with secret "secret/data/traefik/basicauth" }}
          {{- .Data.data.username }}:{{ .Data.data.passwordhash -}}
          {{ end }}
        EOF
        destination = "local/.htpasswd"
      }

      template {
        data = <<-EOF
          CONSUL_HTTP_TOKEN="{{ with secret "consul/creds/traefik" }}{{ .Data.token }}{{ end }}"
        EOF
        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = 256
        memory = 256
      }
    }
  }
}
