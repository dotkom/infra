data "aws_iam_policy_document" "backend" {
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

resource "aws_iam_role" "backend" {
  name               = "grades-prd-backend-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.backend.json
}
