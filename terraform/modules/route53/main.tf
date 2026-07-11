data "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0

  name         = var.domain_name
  private_zone = false
}

locals {
  zone_id = var.domain_name != "" ? data.aws_route53_zone.main[0].zone_id : ""
}

resource "aws_route53_record" "app" {
  count = var.domain_name != "" && local.zone_id != "" ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana" {
  count = var.domain_name != "" && local.zone_id != "" && var.grafana_hostname != "" ? 1 : 0

  zone_id = local.zone_id
  name    = var.grafana_hostname
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}