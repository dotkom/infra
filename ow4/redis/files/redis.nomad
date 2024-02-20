job "redis" {
  datacenters = ["aws-eu-north-1"]
  type        = "service"

  vault {
		policies    = ["redis"]
		change_mode = "noop"
	}

	group "redis" {
		count = 1
		network {
			mode = "bridge"
      port "redis" { to = 6279 }
      port "envoy_metrics" { to = 9102 }
		}

    service {
      name = "redis"
      port = "redis"

      meta {
        envoy_metrics_port = "${NOMAD_HOST_PORT_envoy_metrics}"
      }

      check {
        type = "script"
        name = "redis"
        task = "redis"
        command = "/bin/sh"
        args = ["-c", "[ \"$(redis-cli ping)\" = 'PONG' ] && exit 0; exit 1"]
        interval = "60s"
        timeout  = "5s"
      }
    }

		task "redis" {
			driver = "docker"
			config {
				image = "redis:6.2"
				ports = ["redis"]
			}
      resources {
        cpu = 100
        memory = 128
      }
		}
	}
}
