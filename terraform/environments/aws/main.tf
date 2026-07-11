module "vpc" {

  source = "../../modules/vpc"

  project_name = var.project_name

  environment = var.environment

  cluster_name = var.cluster_name

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

}

module "iam" {

  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment

  cluster_oidc_issuer = module.eks.cluster_oidc_issuer
}

module "ecr" {

  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repositories = [

    "frontend",

    "userservice",

    "contacts",

    "accounts-db",

    "ledger-db",

    "balancereader",

    "ledgerwriter",

    "transactionhistory",

    "loadgenerator"

  ]

}

module "eks" {

  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn

  node_instance_types = var.node_instance_types

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size

}

module "rds" {

  source = "../../modules/rds"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  database_password = var.database_password

  eks_node_security_group_id    = module.eks.node_security_group_id
  eks_cluster_security_group_id = module.eks.cluster_security_group_id

  depends_on = [module.vpc, module.eks]

}

# Comment out monitoring for now
# module "monitoring" {
#
#  source = "../../modules/monitoring"
#
#  project_name          = var.project_name
#  environment           = var.environment
#  grafana_admin_password = var.grafana_admin_password
#  grafana_hostname       = var.grafana_hostname
#
#  depends_on = [module.eks]
#
# }

module "route53" {

  source = "../../modules/route53"

  project_name   = var.project_name
  environment    = var.environment
  domain_name    = var.domain_name
  grafana_hostname = var.grafana_hostname

  alb_dns_name  = module.eks.alb_dns_name
  alb_zone_id   = module.eks.alb_zone_id

  depends_on = [module.eks]

}
