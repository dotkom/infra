variable "openstack_cloud" {
  description = "Named cloud in the local clouds.yaml selected via OS_CLIENT_CONFIG_FILE."
  type        = string
  default     = "openstack"
}

variable "network_id" {
  description = "Existing project network UUID with a router providing internet access."
  type        = string
}

variable "floating_ip_pool" {
  description = "External network name offering publicly reachable IPv4 floating IPs."
  type        = string
}

variable "floating_ip_subnet_id" {
  description = "Public IPv4 floating-IP subnet UUID when the external network has multiple subnets."
  type        = string
  default     = null
}

variable "image_id" {
  description = "Ubuntu 24.04 cloud image UUID (cloud-init enabled)."
  type        = string
}

variable "flavor_name" {
  description = "Existing flavor name; choose at least 1 vCPU, 2 GiB RAM and 20 GiB root disk."
  type        = string
}

variable "key_pair_name" {
  description = "Existing OpenStack SSH key pair name."
  type        = string
}

variable "deployment_ssh_public_key" {
  description = "Additional shared deployment public key installed on new VMs. Never supply a private key."
  type        = string
  default     = ""
}

variable "ssh_allowed_cidrs" {
  description = "Administrator IPv4 CIDRs permitted to SSH; public SSH is forbidden."
  type        = set(string)

  validation {
    condition = length(var.ssh_allowed_cidrs) > 0 && alltrue([
      for cidr in var.ssh_allowed_cidrs : can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"
    ])
    error_message = "Provide administrator IPv4 CIDRs; do not use 0.0.0.0/0."
  }
}

variable "organization_creator_emails" {
  description = "Trusted accounts allowed to create the Online organization."
  type        = set(string)

  validation {
    condition = length(var.organization_creator_emails) > 0 && alltrue([
      for email in var.organization_creator_emails : can(regex("^[^@,[:space:]]+@[^@,[:space:]]+\\.[^@,[:space:]]+$", email))
    ])
    error_message = "Provide at least one organization creator email address."
  }
}

variable "google_sso_enabled" {
  description = "Enable Google-only login after OAuth credentials are installed on the VM."
  type        = bool
  default     = false
}

variable "data_volume_size" {
  description = "Persistent Vaultwarden data volume size in GiB, including local backups."
  type        = number
  default     = 20

  validation {
    condition     = var.data_volume_size >= 10 && floor(var.data_volume_size) == var.data_volume_size
    error_message = "Use an integer of at least 10 GiB."
  }
}
