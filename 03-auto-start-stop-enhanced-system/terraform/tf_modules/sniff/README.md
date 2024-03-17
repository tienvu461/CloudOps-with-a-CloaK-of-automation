# Usage

``` tf
module "sns2webhook_noti_forwarder" {
  source      = "../../../../tf_modules/aws-noti-forwarder"
  name_prefix = local.name_prefix
  common_tags = local.common_tags

  forwarder_type = "sns2webhook"
  python_runtime = "python3.9"
  lambda_environments = {
    "ENV"         = "dev"
    "APP"     = "powertech"
    "WEBHOOK_URL" = "https://webhook.example.com"
  }
}

# SNS topic subscription
resource "aws_lambda_permission" "sns2webhook_noti_forwarder" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.sns2webhook_noti_forwarder.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}

resource "aws_sns_topic_subscription" "sns2webhook_noti_forwarder" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = module.sns2webhook_noti_forwarder.lambda_function_arn
}

```
