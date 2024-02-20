resource "vault_aws_secret_backend" "aws" {
  path                      = "aws"
  region                    = "eu-north-1"
  default_lease_ttl_seconds = 1800
  max_lease_ttl_seconds     = 2678400
}