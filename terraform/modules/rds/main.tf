# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "${lower(var.project_name)}-${var.environment}-db-sg"
  subnet_ids = var.private_subnets

  tags = {
    Name        = "${lower(var.project_name)}-${var.environment}-db-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow PostgreSQL traffic from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id, var.eks_cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Accounts Database
resource "aws_db_instance" "accounts_db" {
  identifier           = "${lower(var.project_name)}-${var.environment}-accounts-db"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_name  = "accountsdb"
  username = "postgres"
  password = var.database_password

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name        = "${lower(var.project_name)}-${var.environment}-accounts-db"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Ledger Database
resource "aws_db_instance" "ledger_db" {
  identifier           = "${lower(var.project_name)}-${var.environment}-ledger-db"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_name  = "ledgerdb"
  username = "postgres"
  password = var.database_password

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name        = "${lower(var.project_name)}-${var.environment}-ledger-db"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}