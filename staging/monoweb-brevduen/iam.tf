data "aws_iam_policy_document" "brevduen" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "brevduen" {
  name               = "monoweb-stg-brevduen-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.brevduen.json
}

data "aws_iam_policy_document" "brevduen_permissions" {
  statement {
    sid       = "GatewayEmailSendSES"
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "brevduen_permissions" {
  name   = "monoweb-stg-brevduen-permissions"
  policy = data.aws_iam_policy_document.brevduen_permissions.json
}

resource "aws_iam_role_policy_attachment" "brevduen_permissions" {
  role       = aws_iam_role.brevduen.name
  policy_arn = aws_iam_policy.brevduen_permissions.arn
}
