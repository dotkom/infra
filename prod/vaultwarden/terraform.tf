terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "vaultwarden.tfstate"
    region = "eu-north-1"
  }

  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Use OS_* environment variables or OS_CLOUD with a local clouds.yaml.
# The Horizon URL is not the Keystone API endpoint; use the downloaded RC file.
provider "openstack" {
  cloud = var.openstack_cloud
}
