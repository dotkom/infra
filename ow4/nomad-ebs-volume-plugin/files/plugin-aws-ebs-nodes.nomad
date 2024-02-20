job "plugin-aws-ebs-nodes" {
    datacenters = ["aws-eu-north-1"]
    type = "system"
    group "nodes" {
        task "plugin" {
            driver = "docker"
            config {
                image = "amazon/aws-ebs-csi-driver:v1.4.0"
                args = [
                    "all",
                    "--endpoint=unix://csi/csi.sock",
                    "--logtostderr",
                    "--v=5",
                ]
                privileged = true
            }
            csi_plugin {
                id        = "aws-ebs"
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