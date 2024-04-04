variable "public_domain_name" {
  description = "Public domain name of the service"
  type        = string
}

variable "certificate_name" {
  description = "Name of the certificate"
  type        = string
}

variable "san" {
  description = "Subject Alternative Name"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

locals {
  tags_all = merge(var.tags, {
    Module = "aws-lightsail-certificate"
  })
}
