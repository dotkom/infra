resource "aws_iam_role" "rpc" {
  name               = "monoweb-prd-rpc-ecs-task-role"
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

data "aws_iam_policy_document" "rpc_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      "arn:aws:s3:::cdn.online.ntnu.no/*"
    ]
  }
}

resource "aws_iam_policy" "rpc_permissions" {
  name   = "monoweb-prd-rpc-permissions"
  policy = data.aws_iam_policy_document.rpc_permissions.json
}

resource "aws_iam_role_policy_attachment" "rpc_permissions" {
  role       = aws_iam_role.rpc.name
  policy_arn = aws_iam_policy.rpc_permissions.arn
}
