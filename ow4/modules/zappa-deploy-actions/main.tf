resource "aws_iam_user" "deploy" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.deploy.name
  policy_arn = aws_iam_policy.deploy_policy.arn
}

resource "aws_iam_policy" "deploy_policy" {
  name   = "onlineweb4-deploy-policy"
  policy = data.aws_iam_policy_document.deploy_ro.json
}

data "aws_iam_policy_document" "deploy_ro" {
  # from https://github.com/zappa/Zappa/blob/master/example/policy/deploy.json

  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:GetRole",
      "iam:PutRolePolicy",
    ]
    effect = "Allow"
    # If we want to be more specific here we should throw zappa out the window
    resources = ["*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*-ZappaLambdaExecutionRole"]
  }

  statement {
    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:GetPolicy",
      "lambda:InvokeFunction",
      "lambda:ListVersionsByFunction",
      "lambda:RemovePermission",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources",
      "cloudformation:UpdateStack",
      "logs:DescribeLogStreams",
      "logs:DeleteLogGroup",
      "logs:FilterLogEvents",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]
    effect    = "Allow"
    resources = [var.deploy_bucket_arn]
  }

  # necessary to update the S3-bucket
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
    ]
    effect    = "Allow"
    resources = ["${var.deploy_bucket_arn}/*"]
  }

  statement {
    actions = [
      "apigateway:OPTIONS",
      "apigateway:DELETE",
      "apigateway:GET",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:ListRuleNamesByTarget",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "SNS:ListSubscriptionsByTopic",
      "SNS:Unsubscribe",
      "SNS:Subscribe",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    effect    = "Allow"
    resources = [data.aws_ecr_repository.repo.arn]
  }
}

resource "aws_iam_access_key" "token" {
  user = aws_iam_user.deploy.name
}

resource "github_repository_environment" "this" {
  environment = var.environment
  repository  = var.github_repository

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_actions_environment_secret" "aws_secret_key_id" {
  environment     = github_repository_environment.this.environment
  repository      = var.github_repository
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.token.id
}

resource "github_actions_environment_secret" "aws_secret_key" {
  environment     = github_repository_environment.this.environment
  repository      = var.github_repository
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.token.secret
}
