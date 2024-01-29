provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name = "aws-zeus"
      ManagedBy = "Terraform"
      DevelopedBy = "LeoFVO - contact@leofvo.me"
      SourceCode = "https://github.com/LeoFVO/aws-zeus"
    }
  }
}
