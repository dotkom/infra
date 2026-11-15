resource "aws_budgets_budget" "this" {
  name        = var.budget_name
  budget_type = var.budget_type
  time_unit   = var.time_unit

  metrics = ["UnblendedCost"]

  auto_adjust_data {
    auto_adjust_type = "HISTORICAL"
    historical_options {
      budget_adjustment_period = var.adjustment_period
    }
  }

  filter_expression {
    dimensions {
      key    = var.filter_key
      values = var.filter_value
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.alert_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = var.trigger_type
    subscriber_email_addresses = var.alert_email
  }
}
