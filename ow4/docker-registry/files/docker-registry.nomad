
job "docker-registry" {
	region = "global"
	datacenters = ["aws-eu-north-1"]
  type = "service"

  vault {
    policies = ["docker-registry"]
    change_mode = "noop"
  }

	group "registry" {
		count = 1

		network {
      mode = "bridge"
      port "registry" {}
      port "metrics" {}
      port "envoy_metrics" { to = 9102 }
    }

    service {
      name = "docker-registry"
      port = "registry"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.docker-registry.rule=Host(`docker-registry.service.consul`)",
        "traefik.http.middlewares.docker-registry-ipwhitelist.ipwhitelist.sourcerange=172.31.0.0/16", # Local VPC cidr block
        "traefik.http.routers.docker-registry.middlewares=docker-registry-ipwhitelist@consulcatalog"
        ]
      meta {
        metrics_port = "${NOMAD_HOST_PORT_metrics}"
        metrics_path = "/metrics"
      }
      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "docker-registry-ui"
      port = 80
      tags = [
        "traefik.enable=true",
				"traefik.consulcatalog.connect=true",
        "traefik.http.routers.docker-registry-ui.rule=Host(`docker-registry.online.ntnu.no`)",
        "traefik.http.routers.docker-registry-ui.middlewares=default-basicauth@consul",
      ]

      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
      }

      check {
        expose   = true
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
      connect {
        sidecar_service {
				}
			}
    }

		task "registry" {
			driver = "docker"
      leader = true
			config {
        image = "registry:2.7.1"
        ports = ["registry", "metrics"]
        volumes = [ "secrets/conf.yml:/etc/docker/registry/config.yml" ]
			}

      template {
        destination = "secrets/conf.yml"
        change_mode = "restart"
        data = <<-EOF
          version: 0.1
          log:
              lebel: info
              fields:
                  service: registry
          http:
              addr: 0.0.0.0:{{ env "NOMAD_PORT_registry" }}
              host: https://docker-registry.online.ntnu.no
              secret: "{{ with secret "secret/data/docker-registry" }}{{ .Data.secret }}{{ end }}"
              debug:
                  addr: 0.0.0.0:{{ env "NOMAD_PORT_metrics" }}
                  prometheus:
                      enabled: true

          storage:
              s3:
                  region: eu-north-1
                  regionendpoint: s3.eu-north-1.amazonaws.com
                  bucket: docker-registry.dotkom
                  {{ with secret "aws/creds/docker-registry" }}
                  accesskey: {{ .Data.access_key }}
                  secretkey: {{ .Data.secret_key }}
                  {{ end }}
              redirect:
                  disable: true
          EOF
		  }
	  }

    task "ui" {
			driver = "docker"
			config {
        image = "joxit/docker-registry-ui"
			}
      template {
          destination = "local/file.env"
          change_mode = "restart"
          env = true
          data = <<-EOF
            REGISTRY_TITLE="Online Docker Registry"
            NGINX_PROXY_PASS_URL=http://localhost:{{ env "NOMAD_PORT_registry" }}
            SINGLE_REGISTRY="true"
            DELETE_IMAGES="true"
            EOF
		  }
	  }
  }
}