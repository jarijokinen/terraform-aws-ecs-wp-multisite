data "aws_cloudfront_function" "maintenance_mode" {
  name  = "maintenance_mode"
  stage = "LIVE"
}

resource "aws_cloudfront_distribution" "site" {
  enabled         = true
  is_ipv6_enabled = true

  aliases = [var.site_domain_name]

  origin {
    domain_name = var.lb_dns_name
    origin_id   = "wp"

    custom_header {
      name  = "X-Secret-Header"
      value = var.lb_secret_header
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "wp"
    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    ]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers      = ["Host"]
      query_string = true

      cookies {
        forward = "all"
      }
    }

    dynamic "function_association" {
      for_each = var.maintenance_mode_enabled ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = data.aws_cloudfront_function.maintenance_mode.arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}
