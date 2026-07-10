resource "aws_eks_access_entry" "admin" {

  cluster_name = aws_eks_cluster.this.name

  principal_arn = data.aws_caller_identity.current.arn

  type = "STANDARD"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_eks_access_policy_association" "admin" {

  cluster_name  = aws_eks_cluster.this.name

  principal_arn = aws_eks_access_entry.admin.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}