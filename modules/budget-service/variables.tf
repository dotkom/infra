variable "budget_name" {
  description = "name of the budget"
  type        = string
}
variable "budget_type" {
  description = "COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, or SAVINGS_PLANS_COVERAGE"
  type        = string
  default     = "COST"
}
variable "limit_amount" {
  description = "amount to budget"
  type        = number
}
variable "limit_unit" {
  description = "the limit unit ex. usd"
  type        = string
  default     = "USD"
}
variable "time_unit" {
  description = "DAILY, MONTHLY, QUARTERLY, or ANNUALLY"
  type        = string
  default     = "MONTHLY"
}
variable "filter_key" {
  description = "SERVICE, LINKED_ACCOUNT, or REGION"
  type        = string
}
variable "filter_value" {
  description = "ex. [\"Amazon Simple Storage Service\""
  type        = list(string)
}
variable "alert_threshold" {
  description = "the precentage value for alerts"
  type        = number
  default     = 100
}
variable "alert_email" {
  description = "the recipient emails of alerts"
  type        = list(string)
}
