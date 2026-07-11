variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "cluster_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_types" {

  type = list(string)

  default = [
    "t3.medium"
  ]

}

variable "desired_size" {

  default = 2

}

variable "min_size" {

  default = 2

}

variable "max_size" {

  default = 4

}

variable "domain_name" {
  type        = string
  description = "Domain name for the application"
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_hostname" {
  type = string
}
