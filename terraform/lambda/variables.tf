variable "aws_region" {
  type = string
  description = "The AWS region to deploy the Lambda function"
}

variable "cloudtrail_bucket" {
  type = object({
    id = string
    arn = string
  })
  description = "The bucket object that stores CloudTrail logs"
}

variable "function_bucket" {
 type = object({
    id = string
    arn = string
  })
  description = "The bucket object that stores AWS Lambda code"
}

variable "function_folder" {
  type = string
  description = "The name of the folder that contains the Lambda function code"
}

variable "environment_variables" {
  type = map(string)
  description = "A map of environment variables to pass to the Lambda function"
}