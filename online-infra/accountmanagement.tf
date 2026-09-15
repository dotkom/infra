resource "aws_account_primary_contact" "root" {
  address_line_1     = "Sem Sælands vei 9"
  city               = "Trondheim"
  company_name       = "ONLINE LINJEFORENINGEN FOR INFORMATIKK"
  country_code       = "NO"
  district_or_county = "Trondheim"
  full_name          = "Andrej Lazic"
  phone_number       = "+4746747280"
  postal_code        = "7034"
  state_or_region    = "Trondheim"
  website_url        = "https://online.ntnu.no"
}

locals {
  dotkom_leader = {
    name  = "Brage Andreas Hoven"
    title = "Operations and Security Manager"
    email = "brage.andreas.hoven@online.ntnu.no"
    phone = "+47 954 71 333"
  }
}

resource "aws_account_alternate_contact" "operations" {
  alternate_contact_type = "OPERATIONS"

  name          = local.dotokom_leader.name
  title         = local.dotkom_leader.title
  email_address = local.dotkom_leader.email
  phone_number  = local.dotkom_leader.phone
}

resource "aws_account_alternate_contact" "billing" {
  alternate_contact_type = "BILLING"

  name          = "Sofie Regine Kjølaas"
  title         = "Financial Manager"
  email_address = "sofie.regine.kjolaas@online.ntnu.no"
  phone_number  = "+47 991 03 761"
}

resource "aws_account_alternate_contact" "security" {
  alternate_contact_type = "SECURITY"

  name          = local.dotokom_leader.name
  title         = local.dotkom_leader.title
  email_address = local.dotkom_leader.email
  phone_number  = local.dotkom_leader.phone
}
