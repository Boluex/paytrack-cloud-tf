############################################
# ALB Security Group - public facing
############################################
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow inbound HTTP/HTTPS from the internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb-sg" })
}

############################################
# ECS Service Security Group - only from ALB
############################################
resource "aws_security_group" "ecs_service" {
  name        = "${var.name_prefix}-ecs-service-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-ecs-service-sg" })
}

############################################
# EC2 Security Group - internal only (SSM, no SSH from internet)
############################################
resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "EC2 instances - access restricted to VPC CIDR"
  vpc_id      = var.vpc_id

  ingress {
    description = "Internal VPC traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-ec2-sg" })
}

############################################
# Lambda Security Group - for VPC-attached Lambdas
############################################
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Lambda functions running inside the VPC"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-lambda-sg" })
}
