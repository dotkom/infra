resource "aws_sns_topic" "cloudwatch_alarm_topic" {
  name = "batman-staging"
}

resource "aws_sns_topic_subscription" "cloudwatch_alarm_topic_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarm_topic.arn
  protocol  = "email"
  endpoint  = "henrik.skog@online.ntnu.no"
}
resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm" {
  alarm_name                = "Websocket ApiGateway MessageCount batman-staging"
  alarm_description         = "This metric monitors the number of messages sent to the websocket api"
  actions_enabled           = true
  ok_actions                = []
  alarm_actions             = [aws_sns_topic.cloudwatch_alarm_topic.arn]
  insufficient_data_actions = []
  metric_name               = "MessageCount"
  namespace                 = "AWS/ApiGateway"
  statistic                 = "SampleCount"
  period                    = 60 * 5 // Client pings every 3 minutes. If volume is 0 for 5 minutes, it has stopped.
  dimensions = {
    Stage = "$default"
    ApiId = "y2nndako0h"
  }
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
}
