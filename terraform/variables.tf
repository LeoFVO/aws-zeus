variable "aws_region" {
  default = "us-east-1"
  description = "The AWS region to deploy the stack"
}

variable "is_aws_organization" {
  description = "Determine if you want to deploy the stack in an AWS Organization"
  type        = bool
  default = false
}