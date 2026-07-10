resource "aws_eks_cluster" "this" {

  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  access_config {

    authentication_mode = "API_AND_CONFIG_MAP"

    bootstrap_cluster_creator_admin_permissions = true

  }

  vpc_config {

    subnet_ids = var.private_subnets

    endpoint_private_access = true

    endpoint_public_access = true

    public_access_cidrs = [
      "0.0.0.0/0"
    ]

  }

  enabled_cluster_log_types = [

    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"

  ]

  tags = {

    Name        = var.cluster_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

  depends_on = []

}