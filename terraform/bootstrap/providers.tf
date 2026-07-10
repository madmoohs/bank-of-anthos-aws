provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner      = var.owner
      Project    = var.project_name
      Repository = "github.com/madmoohs/bank-of-anthos"
      ManagedBy  = "Terraform"
      Stage      = "bootstrap"
    }
  }
}