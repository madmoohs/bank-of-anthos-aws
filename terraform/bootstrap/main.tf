###############################################################
# Current AWS Account
###############################################################

data "aws_caller_identity" "current" {}

###############################################################
# Random suffix for globally unique S3 bucket name
###############################################################

resource "random_id" "bucket_suffix" {
  byte_length = 3
}

###############################################################
# Local Naming Convention
###############################################################

locals {
  name_prefix = lower("${var.owner}-${var.project_name}")

  terraform_state_bucket = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}-${random_id.bucket_suffix.hex}"

  terraform_lock_table = "${local.name_prefix}-terraform-locks"
}

###############################################################
# Terraform State Bucket
###############################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.terraform_state_bucket

  tags = {
    Name = "${var.owner} Terraform State"
  }
}

###############################################################
# Bucket Versioning
###############################################################

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

###############################################################
# Server Side Encryption
###############################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

###############################################################
# Block All Public Access
###############################################################

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

###############################################################
# Enforce Bucket Ownership
###############################################################

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

###############################################################
# DynamoDB Table for Terraform State Locking
###############################################################

resource "aws_dynamodb_table" "terraform_lock" {

  name         = local.terraform_lock_table
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.owner} Terraform Locks"
  }
}