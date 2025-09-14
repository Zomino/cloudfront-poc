resource "aws_s3_bucket" "cloudfront_poc" {
  bucket = format("%s-frontend", var.project_name)
}