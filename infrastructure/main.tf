resource "aws_s3_bucket" "spa_s3_bucket" {
  bucket = var.spa_bucket_name

  tags = {
    Name        = "SPA Bucket"
  }
}