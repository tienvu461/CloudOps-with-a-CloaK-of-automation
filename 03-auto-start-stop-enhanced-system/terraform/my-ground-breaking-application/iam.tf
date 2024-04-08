data "aws_caller_identity" "current" {}

resource "aws_iam_role" "asses_role" {
  name = "${local.prefix}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "asses_policy" {
  role       = aws_iam_role.asses_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "asses_ec2_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "asses_ec2_policy" {
  name        = "asses_ec2_policy"
  path        = "/"
  description = "Allow ASSes access on EC2"
  policy      = data.aws_iam_policy_document.asses_ec2_policy.json
}

resource "aws_iam_role_policy_attachment" "asses_ec2_policy" {
  role       = aws_iam_role.asses_role.name
  policy_arn = aws_iam_policy.asses_ec2_policy.arn
}
