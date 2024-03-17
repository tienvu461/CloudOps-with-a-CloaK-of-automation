locals {
  common_tags = {
    "Manage_by"   = "Terraform"
    "Environment" = "dev"
  }
  prefix = "${var.app}-${var.env}"
}
