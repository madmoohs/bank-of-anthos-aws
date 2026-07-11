output "grafana_url" {
  value = var.grafana_hostname != "" ? "https://${var.grafana_hostname}" : ""
}

output "prometheus_url" {
  value = "http://prometheus-server.monitoring.svc.cluster.local"
}

output "alertmanager_url" {
  value = "http://alertmanager.monitoring.svc.cluster.local"
}