terraform {
  required_version = "~> 0.12.0"

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.32"
  region  = var.region
  profile = var.profile

  assume_role {
    role_arn = var.assume_role_arn
  }
}

# TODO: Create your resources here.
