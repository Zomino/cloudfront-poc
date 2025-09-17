# See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Access Identity for Frontend Website"
}

resource "aws_cloudfront_distribution" "cf_poc" {
  enabled             = true
  default_root_object = "index.html"
  origin {
    origin_id   = "cf_poc_s3_origin"
    domain_name = aws_s3_bucket.cf_poc.bucket_regional_domain_name
    s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  origin {
    origin_id   = "cf_poc_alb_origin"
    domain_name = aws_lb.cf_poc.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443 # Mandatory
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"] # Mandatory
    }
  }
  default_cache_behavior {
    target_origin_id       = "cf_poc_s3_origin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    target_origin_id         = "cf_poc_alb_origin"
    path_pattern             = "/api*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
  }
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
