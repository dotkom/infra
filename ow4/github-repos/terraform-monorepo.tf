## This should probably almost never be modified.
## These resources are related to the current repo.
module "terraform-repos" {
  source = "../modulesithub-repo"

  name                   = "terraform-monorepo"
  description            = "Dotkom's IaC monorepo"
  required_status_checks = ["Terraform fmt"]
}
