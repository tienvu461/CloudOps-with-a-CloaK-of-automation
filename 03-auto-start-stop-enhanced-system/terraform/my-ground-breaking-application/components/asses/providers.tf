provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      "Manage_by"   = "Terraform"
      "App"         = var.app
      "Environment" = var.env
    }
  }
}

terraform {
  required_version = ">= 1.4.6"
  backend "s3" {}
  required_providers {
    aws = {
    version = ">= 5.0.0" }
  }
}
