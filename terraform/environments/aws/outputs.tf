output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "eks_cluster_role_arn" {

  value = module.iam.cluster_role_arn

}

output "eks_node_role_arn" {

  value = module.iam.node_role_arn

}

output "ecr_repository_urls" {

  value = module.ecr.repository_urls

}

output "eks_cluster_name" {

  value = module.eks.cluster_name

}

output "eks_endpoint" {

  value = module.eks.cluster_endpoint

}

/*output "eks_oidc_issuer" {

  value = module.eks.cluster_oidc_issuer

}*/

output "nodegroup_name" {

  value = module.eks.nodegroup_name

}

/*output "oidc_provider_arn" {

  value = module.oidc.oidc_provider_arn

}*/

/*output "oidc_provider_url" {

  value = module.oidc.oidc_provider_url

}*/