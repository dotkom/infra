
provider "aws" {
  region = "eu-north-1"
}
provider "github" {
  owner = "dotkom"
}

provider "vault" {
  address = "https://vault.online.ntnu.no:8200"
}
