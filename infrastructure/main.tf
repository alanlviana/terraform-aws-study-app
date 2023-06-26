resource "aws_s3_bucket" "spa_s3_bucket" {
  bucket = var.spa_bucket_name

  tags = {
    Name        = "SPA Bucket"
  }
}

resource "aws_iam_role" "lambda_notification_s3_role" {
  name = "lambda_notification_s3_role"
  assume_role_policy = file("src/iam/lambda_policy.json")
}

data "archive_file" "lambda_notification_s3_file" {
  type        = "zip"
  output_path = "/tmp/lambda_notification_s3_file.zip"
  source {
    content  = file("src/lambda_notification_s3/main.js")
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda_notification_s3" {
  function_name = "lambda_notification_s3"
  filename         = "${data.archive_file.lambda_notification_s3_file.output_path}"
  source_code_hash = "${data.archive_file.lambda_notification_s3_file.output_base64sha256}"
  role          = aws_iam_role.lambda_notification_s3_role.arn
  handler       = "exports.handler"
  runtime = "nodejs18.x"
  depends_on = [
    aws_iam_role.lambda_notification_s3_role
  ]
}