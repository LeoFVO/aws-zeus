resource "aws_s3_object" "this" {
  bucket = var.function_bucket.id

  key    = "${var.function_folder}.zip"
  source = data.archive_file.this.output_path

  etag = filemd5(data.archive_file.this.output_path)
}

# configures the Lambda function to use the bucket object containing your function code. It also sets the runtime to NodeJS 12.x, and assigns the handler to the handler function defined in hello.js. The source_code_hash attribute will change whenever you update the code contained in the archive, which lets Lambda know that there is a new version of your code available. Finally, the resource specifies a role which grants the function permission 
resource "aws_lambda_function" "this" {
  function_name = "function-${var.function_folder}"

  s3_bucket = var.function_bucket.id
  s3_key    = aws_s3_object.this.key

  runtime = "python3.9"
  handler = "main.handler"

  source_code_hash = data.archive_file.this.output_base64sha256

  role = aws_iam_role.this.arn
  
  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_s3_object.this
  ]
}

# defines a log group to store log messages from your Lambda function for 30 days. By convention, Lambda stores logs in a group with the name /aws/lambda/<Function Name>.
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"

  retention_in_days = 30
}

# defines an IAM role that allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "this" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
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

# attaches a policy the IAM role. The AWSLambdaBasicExecutionRole is an AWS managed policy that allows your Lambda function to write to CloudWatch logs.
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AmazonS3ReadOnlyAccess" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_lambda_permission" "AllowS3Invocation" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"

  source_arn = var.cloudtrail_bucket.arn
}


resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = var.cloudtrail_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
