variable "grafana_stack" {
  description = "Grafana Cloud Stack Identifier"
  type        = string
  default     = "1202339"
}

variable "grafana_region" {
  description = "Grafana Cloud Region"
  type        = string
  default     = "prod-eu-north-0"
}

variable "policy_name" {
  description = "Name of the Grafana Cloud Access Policy"
  type        = string
}
