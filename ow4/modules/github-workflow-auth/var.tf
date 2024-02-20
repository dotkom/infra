variable "repo_name" {
  type        = string
  description = "Name of the repo"
}
variable "role_name" {
  type        = string
  description = "Name of the workflow role to create."
}

variable "additional_vault_policies" {
  type        = list(string)
  default     = []
  description = "List of names of vault policies to attah to the token"
}

variable "token_period" {
  type        = number
  default     = 31536000
  description = "Token period to apply"
}

variable "aws_policy_document" {
  type        = string
  default     = null
  description = "AWS policy to attach to the token"
}
