output "terraform_state_bucket" {
  description = "Terraform remote state bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "Terraform state bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_lock_table" {
  description = "Terraform DynamoDB lock table"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}