resource "vault_aws_secret_backend_role" "packer_builder" {
  backend         = vault_auth_backend.aws.path
  name            = "packer-builder"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.packer_builder.json
}

data "aws_iam_policy_document" "packer_builder" {
  statement {
    actions = [
      "ec2:ModifyFleet",
      "ec2:DeleteFleets",
      "ec2:CreateFleet",
      "ec2:DescribeFleets",
      "ec2:CancelSpotInstanceRequests",
      "ec2:ModifySpotFleetRequest",
      "ec2:RequestSpotInstances",
      "ec2:CancelSpotFleetRequests",
      "ec2:DeleteLaunchTemplate",
      "ec2:DescribeLaunchTemplates",
      "ec2:ModifyLaunchTemplate",
      "ec2:CreateLaunchTemplate",
      "ec2:DescribeSpotFleetInstances",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotFleetRequests",
      "ec2:RequestSpotFleet",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

