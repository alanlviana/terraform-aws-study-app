resource "aws_s3_bucket" "spa_s3_bucket" {
  bucket = var.spa_bucket_name

  tags = {
    Name        = "SPA Bucket"
  }
}

resource "aws_iam_policy" "function_notification_s3_policy" {
  name   = var.function_notification_policy
  policy = file("src/iam/lambda_notification_policy.json")
}


resource "aws_iam_role" "lambda_notification_s3_role" {
  name = var.lambda_notification_role_name
  assume_role_policy = file("src/iam/lambda_notification_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "function_notification_s3_policy_attachment" {
  role = aws_iam_role.lambda_notification_s3_role.id
  policy_arn = aws_iam_policy.function_notification_s3_policy.arn

    depends_on = [
    aws_iam_role.lambda_notification_s3_role,
    aws_iam_policy.function_notification_s3_policy
  ]
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
  function_name = var.lambda_notification_name
  filename         = "${data.archive_file.lambda_notification_s3_file.output_path}"
  source_code_hash = "${data.archive_file.lambda_notification_s3_file.output_base64sha256}"
  role          = aws_iam_role.lambda_notification_s3_role.arn
  handler       = "main.handler"
  runtime = "nodejs18.x"
  depends_on = [
    aws_iam_role.lambda_notification_s3_role
  ]
}

resource "aws_cloudwatch_log_group" "lambda_notification_s3_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_notification_s3.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [
    aws_lambda_function.lambda_notification_s3
  ]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_notification_s3.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.spa_s3_bucket.arn

  depends_on = [
    aws_lambda_function.lambda_notification_s3,
    aws_s3_bucket.spa_s3_bucket
  ]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.spa_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_notification_s3.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}