resource "aws_s3_bucket" "cf_poc" {
  bucket = "cloudfront-poc-frontend"
}

resource "aws_s3_bucket_policy" "cf_poc" {
  bucket = aws_s3_bucket.cf_poc.id
  policy = data.aws_iam_policy_document.cf_poc_allow_cf.json
}

data "aws_iam_policy_document" "cf_poc_allow_cf" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [format("%s/*", aws_s3_bucket.cf_poc.arn)]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}