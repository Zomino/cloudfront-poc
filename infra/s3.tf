resource "aws_s3_bucket" "cloudfront_poc" {
  bucket = "cloudfront-poc-frontend"
}

resource "aws_s3_bucket_policy" "cloudfront_poc" {
  bucket = aws_s3_bucket.cloudfront_poc.id
  policy = data.aws_iam_policy_document.cloudfront_poc_policy.json
}

data "aws_iam_policy_document" "cloudfront_poc_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [format("%s/*", aws_s3_bucket.cloudfront_poc.arn)]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_poc.iam_arn]
    }
  }
}