# Create an S3 bucket to store CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "bucket-${var.aws_region}-cloudtrail"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_bucket_ownership" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudtrail_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudtrail_bucket_ownership]

  bucket = aws_s3_bucket.cloudtrail_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "cloudtrail_bucket_versioning" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = "${aws_s3_bucket.cloudtrail_bucket.id}"
  depends_on = [aws_s3_bucket.cloudtrail_bucket]
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [{
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": { 
              "Service": "cloudtrail.amazonaws.com" 
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": { 
              "Service": "cloudtrail.amazonaws.com" 
            },
            "Action": "s3:PutObject",
            "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
            ],
            "Condition": { 
              "StringEquals": { 
                "s3:x-amz-acl": "bucket-owner-full-control" 
              } 
            }
        }]

}
POLICY
}