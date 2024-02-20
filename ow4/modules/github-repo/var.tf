variable "name" {
  type        = string
  description = "Name of the repo"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description for the repo"
}

variable "default_branch" {
  type        = string
  default     = "main"
  description = "Name of the default branch"
}

variable "required_status_checks" {
  type        = list(string)
  default     = []
  description = "List of required status checks"
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Github repo visibility"
}

