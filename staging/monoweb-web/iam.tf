data "aws_iam_policy_document" "web" {
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

resource "aws_iam_role" "web" {
  name               = "monoweb-staging-web-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.web.json
}
