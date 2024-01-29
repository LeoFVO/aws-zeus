# AWS Zeus

Simple serverless framework to watch cloudtrail events and send alerts.

## Objectives

AWS lambda watching cloudtrails logs and trigger on events.
AWS Lambda send alert via webhook url.

## Getting started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS Account](https://aws.amazon.com/)

### Installation

```bash
git clone git@github.com:LeoFVO/aws-zeus.git
```

### Usage

The stack include pre-defined functions that filter some events and trigger alerts.
You can easily add new functions by creating a new folder in the `functions` directory and adding the function code in it.

To add the function to the stack, simply add it in the file [terraform/module.tf](./terraform/module.tf) and setup the variables to fit your need.

Here is a sample:

```hcl
module "name_of_your_function_module" {
  source        = "./lambda"
  aws_region    = var.aws_region

  function_folder = "folder_name_of_your_function"
  environment_variables ={
    WEBHOOK_URL = "YOUR_WEBHOOK_URL",
    BUCKET_REGION = var.aws_region
  }

  cloudtrail_bucket =  module.s3.cloudtrail_bucket
  function_bucket = module.s3.function_bucket

  depends_on = [ module.s3, module.cloudtrail ]
}
```

## Deploy the stack

```bash
cd terraform
tf init
```

### Deploy the stack in AWS Organization

If you want to deploy the stack in an AWS Organization, you need to set the `is_aws_organization` variable to `true`:

```bash
tf apply -var="is_aws_organization=true"
```

**Important:** When deploying the stack in AWS Organization, you will need to deploy the stack on the master account of the organization.

### Deploy the stack in a single account

```bash
tf apply
```

## Troubleshooting

`Call to function "filemd5" failed: open ../out/iam_events_notifier.zip: no such file or directory.`
This error is due to the fact that the zip file is not created yet. You need to create the zip file before running the terraform command. You can do this by running the following command in the `functions/${FUNCTION_FOLDER}` directory:

```bash
export FUNCTION_FOLDER=iam_events_notifier
zip ../out/${FUNCTION_FOLDER}.zip ../functions/${FUNCTION_FOLDER}/\*
```

After that, you can run the terraform command again. It should fail again,
but this time with a different error message. The error should be :
`Error: Provider produced inconsistent final plan`

You have to remove the hand-made zip file before running the terraform command again. You can do this by running the following command:

```bash
rm ../out/${FUNCTION_FOLDER}.zip
```
