output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail_bucket
}

output "function_bucket" {
  value = aws_s3_bucket.function_bucket
}