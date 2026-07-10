data "tls_certificate" "eks" {
  url = var.cluster_oidc_issuer
}

resource "aws_iam_openid_connect_provider" "eks" {

  url = var.cluster_oidc_issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}