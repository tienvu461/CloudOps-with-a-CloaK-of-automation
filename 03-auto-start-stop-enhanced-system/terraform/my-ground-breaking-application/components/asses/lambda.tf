resource "aws_lambda_function" "asses_function" {
  function_name    = "ASSes"
  description      = "AutoStartStopEnhancedSystem"
  memory_size      = "128"
  s3_bucket        = aws_s3_bucket.asses_source.id
  s3_key           = data.aws_s3_object.asses_source_latest.key
  runtime          = "python3.9"
  handler          = "asses.lambda_handler"
  timeout          = 120
  role             = aws_iam_role.asses_role.arn
  source_code_hash = data.archive_file.asses_source_archived.output_base64sha256
  #   source_code_hash = base64encode(data.aws_s3_object.asses_source_latest.body)

  depends_on = [null_resource.asses_source_build]
}

data "archive_file" "asses_source_archived" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/${var.component}.zip"
}

data "aws_s3_object" "asses_source_latest" {
  bucket = aws_s3_bucket.asses_source.id
  key    = "${var.component}-latest.zip"

  depends_on = [null_resource.asses_source_build]
}

resource "null_resource" "asses_source_build" {
  provisioner "local-exec" {
    command = "/bin/bash ./app/build.sh"
    environment = {
      S3_BUCKET = aws_s3_bucket.asses_source.bucket
    }
  }

  triggers = {
    always_run = timestamp()
  }
}
