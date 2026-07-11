output "app_record_fqdn" {
  value = var.domain_name != "" ? aws_route53_record.app[0].fqdn : ""
}

output "grafana_record_fqdn" {
  value = var.grafana_hostname != "" ? aws_route53_record.grafana[0].fqdn : ""
}
