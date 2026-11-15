variable "budget_name" {
  description = "name of the budget"
  type        = string
}
variable "budget_type" {
  description = "COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, or SAVINGS_PLANS_COVERAGE"
  type        = string
  default     = "COST"
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
  description = "what type of service you want to filter for ex. [\"Amazon Simple Storage Service\""
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
variable "trigger_type" {
  description = "the type of trigger for alerts: actual/forecasted"
  type        = string
}
variable "adjustment_period" {
  description = "Number of past months used to calculate the auto-adjusted budget"
  type        = number
  default     = 6
}
