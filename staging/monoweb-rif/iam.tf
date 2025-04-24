data "aws_iam_policy_document" "ecs_task_execution" {
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

resource "aws_iam_role" "ecs_task" {
  name               = "monoweb-stg-rif-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
}
