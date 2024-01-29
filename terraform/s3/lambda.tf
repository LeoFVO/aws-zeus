resource "aws_s3_bucket" "function_bucket" {
  bucket = "bucket-${var.aws_region}-function"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "function_bucket_ownership" {
  bucket = aws_s3_bucket.function_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "function_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.function_bucket_ownership]

  bucket = aws_s3_bucket.function_bucket.id
  acl    = "private"
}