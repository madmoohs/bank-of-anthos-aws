resource "aws_ecr_repository" "repositories" {

  for_each = toset(var.repositories)

  name = "${lower(var.project_name)}/${each.value}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecr_lifecycle_policy" "repositories" {

  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep last 20 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 20

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}