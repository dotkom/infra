
job "atlantis" {
	region = "global"
	datacenters = ["aws-eu-north-1"]
	type = "service"

	group "atlantis" {

		volume "storage" {
			type      = "csi"
			read_only = false
			source    = "atlantis"
			attachment_mode = "file-system"
			access_mode = "multi-node-multi-writer"
		}

		network {
			mode = "bridge"
			port "envoy_metrics" { to = 9102 }
			dns {
        servers = ["169.254.169.253", "8.8.8.8"]
      }
		}

		service {
			name = "atlantis"
			port = "4141"
			tags = [
				"traefik.enable=true",
				"traefik.consulcatalog.connect=true",
				"traefik.http.routers.atlantis.rule=Host(`atlantis.online.ntnu.no`)",
				"traefik.http.routers.atlantis.middlewares=default-basicauth@consul",
				"traefik.http.routers.atlantis-webhook.rule=Host(`atlantis.online.ntnu.no`) && PathPrefix(`/events`)",
			]

			meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
			}

			check {
        expose   = true
        type     = "http"
        path     = "/healthz"
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
				}
			}
		}

		task "atlantis" {
			driver = "docker"
			kill_timeout = "5m"

			vault {
				policies    = ["atlantis"]
				change_mode = "noop"
			}

			config {
				image = "runatlantis/atlantis:v0.17.3"
				volumes = ["secrets/certs/:/etc/atlantis/certs"]
			}

			volume_mount {
				volume      = "storage"
				destination = "/opt/atlantis"
				read_only   = false
			}

			env {
				ATLANTIS_ATLANTIS_URL = "https://atlantis.online.ntnu.no"
				ATLANTIS_GH_USER = "dotkom-machine"
				ATLANTIS_REPO_ALLOWLIST = "github.com/dotkom/terraform-monorepo"
				ATLANTIS_GH_ORG = "dotkom"
				ATLANTIS_DATA_DIR = "/opt/atlantis"

				NOMAD_CACERT="/etc/atlantis/certs/nomad-ca.crt"
				NOMAD_CLIENT_CERT="/etc/atlantis/certs/nomad.crt"
				NOMAD_CLIENT_KEY="/etc/atlantis/certs/nomad.key"

				CONSUL_CACERT="/etc/atlantis/certs/consul-ca.crt"
				CONSUL_CLIENT_CERT="/etc/atlantis/certs/consul.crt"
				CONSUL_CLIENT_KEY="/etc/atlantis/certs/consul.key"
			}

			template {
				destination = "secrets/file.env"
				change_mode = "restart"
				env = true
				data = <<-EOF
					{{ with secret "secret/data/atlantis/github" }}
					ATLANTIS_GH_WEBHOOK_SECRET="{{ .Data.data.webhook_secret }}"
					ATLANTIS_GH_TOKEN="{{ .Data.data.token }}"
					GITHUB_TOKEN="{{ .Data.data.token }}"
					{{ end }}

					{{ with secret "aws/creds/atlantis" }}
					AWS_ACCESS_KEY_ID="{{ .Data.access_key }}"
					AWS_SECRET_ACCESS_KEY="{{ .Data.secret_key }}"
					{{ end }}

					VERCEL_TOKEN="{{ with secret "secret/data/vercel" }}{{ .Data.data.token }}{{ end }}"

					CONSUL_HTTP_TOKEN="{{ with secret "consul/creds/atlantis" }}{{ .Data.token }}{{ end }}"
					NOMAD_TOKEN="{{ with secret "secret/data/nomad/acl/master" }}{{ .Data.data.token }}{{ end }}"
					PGPASSWORD="{{ with secret "postgres/static-creds/atlantis" }}{{ .Data.password }}{{ end }}"
				EOF
			}

			template {
				destination   = "secrets/certs/consul.crt"
				change_mode = "restart"
				data = <<EOF
					{{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
					{{- .Data.certificate -}}
					{{- end -}}
				EOF
      }

			template {
				destination   = "secrets/certs/consul.key"
				change_mode = "restart"
				data = <<EOF
					{{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
					{{- .Data.private_key -}}
					{{- end -}}
				EOF
      }

			template {
				destination   = "secrets/certs/consul-ca.crt"
				change_mode = "restart"
				data = <<EOF
					{{- with secret "pki_int/issue/consul-client" "common_name=client.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
					{{- .Data.issuing_ca -}}
					{{- end -}}
				EOF
      }

			template {
				destination   = "secrets/certs/nomad.crt"
				change_mode = "restart"
				data = <<EOF
					{{- with secret "pki_int/issue/nomad-client" "common_name=client.global.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
					{{- .Data.certificate -}}
					{{- end -}}
				EOF
      }

			template {
				destination   = "secrets/certs/nomad.key"
				change_mode = "restart"
				data = <<EOF
					{{- with secret "pki_int/issue/nomad-client" "common_name=client.global.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1" -}}
					{{- .Data.private_key -}}
					{{- end -}}
				EOF
      }

			template {
				destination   = "secrets/certs/nomad-ca.crt"
				change_mode = "restart"
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
				image = "runatlantis/atlantis:v0.17.3"
				command = "chown"
				args = ["-R", "atlantis:atlantis", "/opt/atlantis"]
			}
			user = "root"
			volume_mount {
				volume      = "storage"
				destination = "/opt/atlantis"
				read_only   = false
			}
			lifecycle {
				hook = "prestart"
				sidecar = false
			}
		}
  }
}
