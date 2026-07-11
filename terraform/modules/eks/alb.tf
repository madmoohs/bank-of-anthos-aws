# ALB for the application
resource "aws_lb" "main" {

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
  vpc_id             = var.vpc_id

  enable_deletion_protection = false

  tags = {

    Name        = "${var.project_name}-${var.environment}-alb"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

# Security Group for ALB
resource "aws_security_group" "alb" {

  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS traffic from the internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

# Target Group for frontend service
resource "aws_lb_target_group" "frontend" {

  name     = "${var.project_name}-${var.environment}-frontend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {

    path                = "/ready"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3

  }

  tags = {

    Name        = "${var.project_name}-${var.environment}-frontend-tg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}

# HTTP Listener - redirect to HTTPS
resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [aws_lb_target_group.frontend]

}

# HTTPS Listener
resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-ES-2024-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  depends_on = [aws_lb_target_group.frontend]

}