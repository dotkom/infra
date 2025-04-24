data "aws_iam_policy_document" "gatus" {
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

resource "aws_iam_role" "gatus" {
  name               = "monoweb-prd-gatus-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.gatus.json
}
