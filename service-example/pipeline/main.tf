terraform {
  required_version = "~> 0.12.0"

  # TODO: Uncomment and update backend configuration here.
  #  backend "s3" {
  #    bucket         = "[PREFIX]-tools-terraform-state"
  #    key            = "service-example-pipeline/terraform.tfstate"
  #    region         = "us-east-1"
  #    dynamodb_table = "[PREFIX]-tools-terraform-state-locking"
  #    profile        = "ops-tools"
  #    encrypt        = true
  #    kms_key_id     = "[KMS_KEY_ID]"
  #  }
}

provider "aws" {
  version = "~> 2.32"
  region  = var.region
  profile = "ops-tools"
}

provider "aws" {
  alias   = "stage"
  version = "~> 2.32"
  region  = var.region
  profile = "ops-stage"
}

provider "aws" {
  alias   = "prod"
  version = "~> 2.32"
  region  = var.region
  profile = "ops-prod"
}

data "aws_caller_identity" "stage" {
  provider = aws.stage
}

data "aws_region" "stage" {
  provider = aws.stage
}

data "aws_iam_role" "stage_ops" {
  provider = aws.stage
  name     = "Ops"
}

data "aws_caller_identity" "prod" {
  provider = aws.prod
}

data "aws_region" "prod" {
  provider = aws.prod
}

data "aws_iam_role" "prod_ops" {
  provider = aws.prod
  name     = "Ops"
}

module "stage" {
  source = "./env-deployer-policy"

  account_id   = data.aws_caller_identity.stage.account_id
  ops_role_arn = data.aws_iam_role.stage_ops.arn
  region       = data.aws_region.stage.name
}

module "prod" {
  source = "./env-deployer-policy"

  account_id   = data.aws_caller_identity.prod.account_id
  ops_role_arn = data.aws_iam_role.prod_ops.arn
  region       = data.aws_region.prod.name
}

module "pipeline" {
  source = "github.com/jdhollis/deployment-pipeline"

  github_token = var.github_token
  github_user  = var.github_user

  env_deployer_policy_json = {
    stage = module.stage.json
    prod  = module.prod.json
  }

  region              = var.region
  remote_state_bucket = "[PREFIX]-tools-terraform-state" # TODO: Insert remote state bucket name here.
  remote_state_key    = "remote-state/terraform.tfstate" # TODO: Insert remote state key here.

  # TODO: Add any required services here to ensure access to the necessary state files.
  #  required_services = [
  #    "…"
  #  ]

  service_name = "service-example"
}
