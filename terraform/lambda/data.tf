data "aws_caller_identity" "current" {}

data "archive_file" "this" {
  type = "zip"

  source_dir  = "${path.module}/../../functions/${var.function_folder}"
  output_path = "${path.module}/../../out/${var.function_folder}.zip"
}
