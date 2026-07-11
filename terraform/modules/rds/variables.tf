variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "eks_node_security_group_id" {
  type = string
}

variable "eks_cluster_security_group_id" {
  type = string
}
