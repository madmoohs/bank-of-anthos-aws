####################################
# EKS Cluster Role
####################################

resource "aws_iam_role" "eks_cluster" {

  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {

  role       = aws_iam_role.eks_cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

####################################
# Node Group Role
####################################

resource "aws_iam_role" "node_group" {

  name = "${var.project_name}-nodegroup-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "worker_node" {

  role       = aws_iam_role.node_group.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "cni" {

  role       = aws_iam_role.node_group.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

resource "aws_iam_role_policy_attachment" "ecr" {

  role       = aws_iam_role.node_group.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.node_group.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

# Cluster Autoscaler Role
resource "aws_iam_role" "cluster_autoscaler" {

  name = "${var.project_name}-cluster-autoscaler"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = var.cluster_oidc_issuer

        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${var.cluster_oidc_issuer}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"

            "${var.cluster_oidc_issuer}:aud" = "sts.amazonaws.com"

          }

        }

      }

    ]

  })

  tags = {

    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {

  role       = aws_iam_role.cluster_autoscaler.name

  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"

}

# External DNS Role
resource "aws_iam_role" "external_dns" {

  name = "${var.project_name}-external-dns"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = var.cluster_oidc_issuer

        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${var.cluster_oidc_issuer}:sub" = "system:serviceaccount:external-dns:external-dns"

            "${var.cluster_oidc_issuer}:aud" = "sts.amazonaws.com"

          }

        }

      }

    ]

  })

  tags = {

    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

resource "aws_iam_role_policy_attachment" "external_dns" {

  role       = aws_iam_role.external_dns.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"

}

# Prometheus Role for monitoring
resource "aws_iam_role" "prometheus" {

  name = "${var.project_name}-prometheus"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = var.cluster_oidc_issuer

        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${var.cluster_oidc_issuer}:sub" = "system:serviceaccount:monitoring:prometheus"

            "${var.cluster_oidc_issuer}:aud" = "sts.amazonaws.com"

          }

        }

      }

    ]

  })

  tags = {

    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

resource "aws_iam_role_policy_attachment" "prometheus" {

  role       = aws_iam_role.prometheus.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}
