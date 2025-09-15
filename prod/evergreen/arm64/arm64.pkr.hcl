packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux-2023" {
  ami_name      = "evergreen-arm64-amazon-linux-2023-{{timestamp}}"
  instance_type = "t4g.small"
  region        = "eu-north-1"
  source_ami_filter {
    filters = {
      # Amazon Linux 2023 arm64 ECS-optimized AMI
      # https://aws.amazon.com/marketplace/server/configuration?productId=55b77dd6-9d60-4122-94df-5bfe4565e2f1&ref_=psb_cfg_continue
      image-id            = "ami-035a3ad2867e0f8a9"
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
      "echo 'ECS_CLUSTER=evergreen-prod-cluster' | sudo tee -a /etc/ecs/ecs.config",
      "echo 'ECS_IMAGE_PULL_BEHAVIOR=prefer-cached' | sudo tee -a /etc/ecs/ecs.config",
      # Install the AWS SSM Agent to allow remote access to the EC2 instance despite the instance not having a public IP.
      "sudo systemctl status amazon-ssm-agent",
      "sudo systemctl stop amazon-ssm-agent",
      "sudo systemctl enable amazon-ssm-agent",
      # Restart ECS Agent to pick up changes in the configuration
      "sudo systemctl stop ecs",
      "sudo systemctl enable ecs",
    ]
  }
}
