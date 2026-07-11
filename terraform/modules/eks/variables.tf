variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.33"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
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

variable "ebs_csi_role_arn" {
  type    = string
  default = ""
}

variable "certificate_arn" {
  type      = string
  sensitive = true
  default   = ""
}