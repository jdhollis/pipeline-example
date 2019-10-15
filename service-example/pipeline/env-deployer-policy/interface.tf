variable "account_id" {}
variable "ops_role_arn" {}
variable "region" {}

output "json" {
  value = data.aws_iam_policy_document.env_deployer.json
}
