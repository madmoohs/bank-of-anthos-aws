resource "aws_eks_node_group" "default" {

  cluster_name = aws_eks_cluster.this.name

  node_group_name = "${var.project_name}-nodegroup"

  node_role_arn = var.node_role_arn

  subnet_ids = var.private_subnets

  instance_types = var.node_instance_types

  capacity_type = "ON_DEMAND"

  disk_size = 50

  ami_type = "AL2023_x86_64_STANDARD"

  labels = {
  workload = "general"
  managed-by = "terraform"
  }

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size

  }

  update_config {

    max_unavailable = 1

  }

  tags = {

    Project = var.project_name

    Environment = var.environment

    ManagedBy = "Terraform"

  }

  depends_on = [

    aws_eks_cluster.this

  ]

  lifecycle {
  create_before_destroy = true
  }
}