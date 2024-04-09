data "aws_iam_policy_document" "open_public_key" {
  version = "2008-10-17"

  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.this.arn}/public/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "open_public_key" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.open_public_key.json
}

resource "aws_s3_bucket" "this" {
  bucket = "batman-state"
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
}
