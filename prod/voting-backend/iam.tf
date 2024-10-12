data "aws_iam_policy_document" "voting" {
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

resource "aws_iam_role" "voting" {
  name               = "VotingProdServerECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.voting.json
}
