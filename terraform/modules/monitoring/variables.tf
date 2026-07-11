variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_hostname" {
  type = string
}

variable "storage_class_name" {
  type    = string
  default = "gp3"
}

variable "prometheus_storage_size" {
  type    = string
  default = "50Gi"
}

variable "alertmanager_storage_size" {
  type    = string
  default = "10Gi"
}