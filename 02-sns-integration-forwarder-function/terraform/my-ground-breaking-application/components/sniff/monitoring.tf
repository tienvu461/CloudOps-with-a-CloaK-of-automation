data "aws_caller_identity" "current" {}

# SNS Topic for notification
resource "aws_sns_topic" "this" {
  name = "${local.prefix}-monitoring-noti"
}

# SNS Topic policy
resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}
# Data policy
data "aws_iam_policy_document" "this" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]

    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.this.arn]
  }
  statement {
    sid = "AWSBudgets"
    actions = [
      "SNS:Publish"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
    resources = [aws_sns_topic.this.arn]
  }
  statement {
    sid     = "CodeStartNotification"
    actions = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    resources = [aws_sns_topic.this.arn]
  }
  statement {
    sid     = "AWSEvents"
    actions = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.this.arn]
  }
}

module "sns2webhook_noti_forwarder" {
  source      = "../../tf_modules/sniff"
  prefix      = var.prefix
  common_tags = local.common_tags

  forwarder_type = "sns2webhook"
  python_runtime = "python3.9"
  lambda_environments = {
    "ENV"         = var.env
    "APP"         = var.app_name
    "WEBHOOK_URL" = var.discord_webhook
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
