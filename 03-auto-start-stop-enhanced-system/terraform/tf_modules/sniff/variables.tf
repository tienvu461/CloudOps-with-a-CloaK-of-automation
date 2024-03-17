variable "prefix" { default = "" }
variable "common_tags" { default = {} }

variable "lambda_handler" { default = "main.lambda_handler" }
variable "lambda_environments" {}
variable "python_runtime" {}
variable "forwarder_type" {
  validation {
    condition     = contains(["sns2webhook", "tbd"], var.forwarder_type)
    error_message = "Invalid forwarder type. Must be one of [sns2webhook,tbd]"
  }
}
