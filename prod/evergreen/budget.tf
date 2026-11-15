locals {
  budgets = {
    elb-forecasted = {
      name         = "ELB-Cost-Alert-Forecasted"
      filter_value = ["Amazon Elastic Load Balancing"]
      trigger_type = "FORECASTED"
    }
    elb-critical = {
      name         = "ELB-Cost-Alert-Critical"
      filter_value = ["Amazon Elastic Load Balancing"]
      trigger_type = "ACTUAL"
    }
    rds-forecasted = {
      name         = "RDS-Cost-Alert-Forecasted"
      filter_value = ["Amazon Simple Storage Service"]
      trigger_type = "FORECASTED"
    }
    rds-critical = {
      name         = "RDS-Cost-Alert-Critical"
      filter_value = ["Amazon Relational Database Service"]
      trigger_type = "ACTUAL"
    }
    ec2-forecasted = {
      name         = "EC2-Cost-Alert-Forecasted"
      filter_value = ["EC2 - Other"]
      trigger_type = "FORECASTED"
    }
    ec2-critical = {
      name         = "EC2-Cost-Alert-Critical"
      filter_value = ["EC2 - Other"]
      trigger_type = "ACTUAL"
    }
    ecs-forecasted = {
      name         = "ECS-Cost-Alert-Forecasted"
      filter_value = ["Amazon Elastic Container Service"]
      trigger_type = "FORECASTED"
    }
    ecs-critical = {
      name         = "ECS-Cost-Alert-critical"
      filter_value = ["Amazon Elastic Container Service"]
      trigger_type = "ACTUAL"
    }
  }
}

module "budget" {
  source   = "../../modules/budget-service"
  for_each = local.budgets

  budget_name  = each.value.name
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  trigger_type = each.value.trigger_type

  filter_key   = "SERVICE"
  filter_value = each.value.filter_value

  alert_threshold = "150"
  alert_email     = ["dotkom@online.ntnu.no"]
}
