job "plugin-aws-efs-nodes" {
	datacenters = ["aws-eu-north-1"]
	type = "system"
	group "nodes" {
		task "plugin" {
			driver = "docker"
			config {
				image = "amazon/aws-efs-csi-driver:master"
				args = [
					"--endpoint=unix://csi/csi.sock",
					"--logtostderr",
					"--v=2",
				]
				privileged = true
			}
			csi_plugin {
				id = "aws-efs"
				type      = "monolith"
				mount_dir = "/csi"
			}
			resources {
				cpu    = 100
				memory = 128
			}
		}
	}
}