locals {
  common_tags = {
    "Manage_by"   = "Terraform"
    "App"         = var.app
    "Environment" = var.env
  }
  prefix = "${var.app}-${var.env}-${var.component}"
}
