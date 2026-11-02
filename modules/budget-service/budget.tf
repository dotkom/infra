resource "aws_budgets_budget" "this" {
  name         = var.budget_name
  budget_type  = var.budget_type
  limit_amount = var.limit_amount
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit

  metrics = ["UnblendedCost"]

  filter_expression {
    dimensions {
      key    = var.filter_key
      values = var.filter_value
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.alert_threshold
    threshold_type             = "PRECENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_email
  }
}
