resource "aws_iam_role" "container" {
  name               = "MonowebStagingKvitteringECSTaskRole2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
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

data "aws_iam_policy_document" "container_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "container_policy" {
  name   = "MonowebStagingKvitteringPermissions"
  policy = data.aws_iam_policy_document.container_permissions.json
}

resource "aws_iam_role_policy_attachment" "container_policy" {
  role       = aws_iam_role.container.name
  policy_arn = aws_iam_policy.container_policy.arn
}
