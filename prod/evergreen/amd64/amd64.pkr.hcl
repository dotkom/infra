packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux-2023" {
  ami_name      = "evergreen-amd64-amazon-linux-2023-{{timestamp}}"
  instance_type = "t3.small"
  region        = "eu-north-1"
  source_ami_filter {
    filters = {
      image-id            = "ami-0ad49b719ae8df301"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "everest-containers"
  sources = ["source.amazon-ebs.amazon-linux-2023"]

  # Wait for cloud-init to finish
  provisioner "shell" {
    inline = [
      "set -euox pipefail",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      # Select ECS Cluster for the ECS Container Agent to use
      "sudo cat /etc/ecs/ecs.config",
      "echo 'ECS_CLUSTER=evergreen-prod-cluster' | sudo tee -a /etc/ecs/ecs.config",
      "sudo systemctl status amazon-ssm-agent",
      "sudo systemctl stop amazon-ssm-agent",
      "sudo systemctl enable amazon-ssm-agent",
      # Restart ECS Agent to pick up changes in the configuration
      "sudo systemctl stop ecs",
      "sudo systemctl enable ecs",
    ]
  }
}
