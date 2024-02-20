resource "vault_auth_backend" "aws" {
  type = "aws"

  tune {
    max_lease_ttl      = "768h"
    default_lease_ttl  = "768h"
    listing_visibility = "unauth"
  }
}
