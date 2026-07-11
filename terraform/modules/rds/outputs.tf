output "accounts_db_endpoint" {
  value = aws_db_instance.accounts_db.endpoint
}

output "ledger_db_endpoint" {
  value = aws_db_instance.ledger_db.endpoint
}

output "accounts_db_address" {
  value = aws_db_instance.accounts_db.address
}

output "ledger_db_address" {
  value = aws_db_instance.ledger_db.address
}