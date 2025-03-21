resource "aws_route53_zone" "wp" {
  name = var.domain_name
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wp.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
    if !startswith(dvo.domain_name, "*")
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.wp.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_route53_record" "a" {
  zone_id = aws_route53_zone.wp.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.wp.domain_name
    zone_id                = aws_cloudfront_distribution.wp.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aaaa" {
  zone_id = aws_route53_zone.wp.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.wp.domain_name
    zone_id                = aws_cloudfront_distribution.wp.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "a_wildcard" {
  zone_id = aws_route53_zone.wp.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.wp.domain_name
    zone_id                = aws_cloudfront_distribution.wp.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aaaa_wildcard" {
  zone_id = aws_route53_zone.wp.zone_id
  name    = "*.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.wp.domain_name
    zone_id                = aws_cloudfront_distribution.wp.hosted_zone_id
    evaluate_target_health = true
  }
}
