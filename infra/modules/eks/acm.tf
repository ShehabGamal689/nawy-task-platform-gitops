# 1. Request the Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "devopsawy.site"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-cert"
  }
}

# 2. Create the DNS Record in Route 53 for Validation
# This "proves" to AWS that you own the domain
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id # Make sure you have a data source for your zone
}

# 3. The "Waiter" - This tells Terraform to wait until the cert is actually ready
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Data source to find your existing Route 53 zone
data "aws_route53_zone" "selected" {
  name         = "devopsawy.site"
  private_zone = false
}
