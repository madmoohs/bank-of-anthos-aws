output "app_record_fqdn" {
  value = aws_route53_record.app.fqdn
}

output "grafana_record_fqdn" {
  value = aws_route53_record.grafana.fqdn
}