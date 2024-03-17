provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      "Manage_by"   = "Terraform"
      "Project"     = var.app
      "Environment" = var.env
    }
  }
}

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {}
  required_providers {
    aws = {
      version = "~> 4.0.0"
    }
  }
}
