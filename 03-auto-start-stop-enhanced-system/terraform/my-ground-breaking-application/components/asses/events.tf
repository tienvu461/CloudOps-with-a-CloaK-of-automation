resource "aws_lambda_permission" "asses_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asses_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:ap-southeast-1:${data.aws_caller_identity.current.account_id}:*"
}

## EOB ##
resource "aws_cloudwatch_event_rule" "eob_scheduler" {
  name        = "EOB"
  description = "Trigger at 18:00 UTC+7 Mon-Fri"
  #   schedule_expression = "cron(0 11 ? * MON-FRI *)"
  schedule_expression = "cron(0 11 ? * * *)"
}

resource "aws_cloudwatch_event_target" "eob_trigger" {
  rule      = aws_cloudwatch_event_rule.eob_scheduler.name
  target_id = "eob_trigger"
  arn       = aws_lambda_function.asses_function.arn
}

# resource "aws_lambda_permission" "eob_2_asses_function" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.asses_function.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.eob_scheduler.arn
# }

## SOB ##
resource "aws_cloudwatch_event_rule" "sob_scheduler" {
  name        = "SOB"
  description = "Trigger at 9:00 UTC+7 Mon-Fri"
  #   schedule_expression = "cron(0 2 ? * MON-FRI *)"
  schedule_expression = "cron(0 2 ? * * *)"
}

resource "aws_cloudwatch_event_target" "sob_trigger" {
  rule      = aws_cloudwatch_event_rule.sob_scheduler.name
  target_id = "sob_trigger"
  arn       = aws_lambda_function.asses_function.arn
}
