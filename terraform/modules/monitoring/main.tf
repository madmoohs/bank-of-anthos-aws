# Kube-prometheus-stack Helm chart for monitoring
resource "helm_release" "monitoring_stack" {

  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  # version          = ">=48.0.0"

  values = [
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
        service = {
          type = "ClusterIP"
        }
        ingress = {
          enabled = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"  = "ip"
            "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}]"
          }
          hosts = [
            var.grafana_hostname
          ]
          tls = [
            {
              secretName = "grafana-tls"
              hosts      = [var.grafana_hostname]
            }
          ]
        }
      }
      prometheus = {
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class_name
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          }
        }
      }
      alertmanager = {
        alertmanagerSpec = {
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class_name
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.alertmanager_storage_size
                  }
                }
              }
            }
          }
        }
      }
    })
  ]

}
