module "s3" {
  source        = "./s3"
  aws_region    = var.aws_region
}

module "cloudtrail" {
  source        = "./cloudtrail"
  bucket = module.s3.cloudtrail_bucket

  include_global_service_events = true
  is_multi_region_trail = true
  is_organization_trail = var.is_aws_organization

  depends_on = [ module.s3 ]
}

module "function_iam_events_notifier" {
  source        = "./lambda"
  aws_region    = var.aws_region
  
  function_folder = "iam_events_notifier"
  environment_variables ={
    WEBHOOK_URL = "YOUR_WEBHOOK_URL"
    BUCKET_REGION = var.aws_region
  }

  cloudtrail_bucket =  module.s3.cloudtrail_bucket
  function_bucket = module.s3.function_bucket

  depends_on = [ module.s3, module.cloudtrail ]
}
