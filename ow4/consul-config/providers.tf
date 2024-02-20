provider "consul" {
  address    = "consul.online.ntnu.no:8501"
  datacenter = "aws-eu-north-1"
  scheme     = "https"
}

provider "vault" {
  address = "https://vault.online.ntnu.no:8200"
}
