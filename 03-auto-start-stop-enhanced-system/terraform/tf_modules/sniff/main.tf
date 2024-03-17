data "aws_caller_identity" "current" {}

resource "aws_iam_role" "noti_forwarder" {
  name = "${var.name_prefix}-lambda-noti-forwarder"

  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "noti_forwarder" {
  role       = aws_iam_role.noti_forwarder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy" "noti_forwarder" {
  role   = aws_iam_role.noti_forwarder.id
  name   = "${var.name_prefix}-lambda-noti-forwarder"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:GetObject",
          "s3:ListObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "noti_forwarder" {
  filename         = local.lambda_file_path
  source_code_hash = filebase64sha256(local.lambda_file_path)
  function_name    = "${var.name_prefix}-lambda-noti-forwarder"
  role             = aws_iam_role.noti_forwarder.arn
  handler          = var.lambda_handler
  runtime          = var.python_runtime
  timeout          = 10
  environment {
    variables = var.lambda_environments
  }
}
