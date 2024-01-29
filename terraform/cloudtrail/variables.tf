variable "bucket" {
  type = object({
    id = string
    arn = string
  }) 
  description = "The bucket object that stores CloudTrail logs"
}

variable "include_global_service_events" {
  type = bool
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  default = true
}

variable "is_multi_region_trail" {
  type = bool
  description = "Specifies whether the trail is created in the current region or in all regions"
  default = true
}

variable "is_organization_trail" {
  type = bool
  description = "Specifies whether the trail is an AWS Organizations trail.\nIf true, you will need to deploy the stack on the main account, cf: \nhttps://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#is_organization_trail"
  default = false
}
