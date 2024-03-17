resource "aws_s3_bucket" "asses_source" {
  bucket = "${local.prefix}-source"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "asses_source" {
  bucket = aws_s3_bucket.asses_source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "asses_source" {
  bucket = aws_s3_bucket.asses_source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

