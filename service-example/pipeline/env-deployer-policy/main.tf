data "aws_iam_policy_document" "env_deployer" {
  statement {
    actions   = ["iam:GetRole"]
    resources = [var.ops_role_arn]
  }

  # TODO: Insert deployer IAM permissions here.
}
