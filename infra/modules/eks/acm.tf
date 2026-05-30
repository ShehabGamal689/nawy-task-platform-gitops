resource "aws_route53_zone" "main" {
  name = "devopsnawy.qzz.io" 
}

resource "null_resource" "update_registrar_ns" {
  triggers = {
    ns_records = join(",", aws_route53_zone.main.name_servers)
  }

  depends_on = [aws_route53_zone.main]

  provisioner "local-exec" {
    
    command = <<EOT
      curl -X PUT "https://domain-api.digitalplat.org/api/v1/domains/devopsnawy.qzz.io/nameservers" \
      -H "Authorization: Bearer ${var.registrar_api_key}" \
      -H "Content-Type: application/json" \
      -d '{
        "nameservers": [
          "${aws_route53_zone.main.name_servers[0]}",
          "${aws_route53_zone.main.name_servers[1]}",
          "${aws_route53_zone.main.name_servers[2]}",
          "${aws_route53_zone.main.name_servers[3]}"
        ]
      }'
    EOT
  }
}


resource "time_sleep" "wait_for_dns_propagation" {
  depends_on      = [null_resource.update_registrar_ns]
  create_duration = "60s"
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "devopsnawy.qzz.io" 
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-cert"
  }
}


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
  zone_id         = aws_route53_zone.main.zone_id 
}


resource "aws_acm_certificate_validation" "cert" {
  depends_on = [
    time_sleep.wait_for_dns_propagation,
    aws_route53_record.cert_validation
  ]
  
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
