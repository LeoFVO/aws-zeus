# Create a CloudTrail trail
resource "aws_cloudtrail" "WriteManagementEventsTrail" {
  name                          = "WriteManagementEventsTrail"
  s3_bucket_name                = var.bucket.id
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail = var.is_organization_trail
  
  advanced_event_selector {
    name = "Log all (write) Management events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }
  }
}
