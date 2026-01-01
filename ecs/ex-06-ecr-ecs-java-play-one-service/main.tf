terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get AWS account ID and region for ECR URL
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets for the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Get default security group
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.repository_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.repository_name}-alb-sg"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.repository_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.repository_name}-ecs-tasks-sg"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# Create ECR repository
resource "aws_ecr_repository" "demo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.repository_name
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# Build and push Docker image to ECR using null_resource
resource "null_resource" "docker_build_push" {
  # Trigger rebuild when Dockerfile or source code changes
  triggers = {
    dockerfile_hash = filemd5("${path.module}/Dockerfile")
    fat_jar_hash    = filemd5("${path.module}/play-ecs-ex-06.jar")
    image_tag       = var.image_tag
    repository_url  = aws_ecr_repository.demo.repository_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login to ECR
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.demo.repository_url}

      # Build the Docker image for linux/amd64 platform
      docker build --platform linux/amd64 -t ${aws_ecr_repository.demo.repository_url}:${var.image_tag} ${path.module}

      # Push the image to ECR
      docker push ${aws_ecr_repository.demo.repository_url}:${var.image_tag}
    EOT
  }

  depends_on = [aws_ecr_repository.demo]
}

# Optional: Lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "demo" {
  repository = aws_ecr_repository.demo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# IAM role for ECS task execution (allows ECS to pull from ECR)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.repository_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.repository_name}-ecs-task-execution-role"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# Attach the AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.repository_name}-cluster"

  tags = {
    Name        = "${var.repository_name}-cluster"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.repository_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"  # 0.5 vCPU
  memory                   = "1024" # 1 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = var.repository_name
    image = "${aws_ecr_repository.demo.repository_url}:${var.image_tag}"

    portMappings = [{
      containerPort = 9000
      protocol      = "tcp"
    }]

    environment = [
      {
        name  = "APPLICATION_SECRET"
        value = var.application_secret
      },
      {
        name  = "MY_FOOBAR"
        value = var.my_foobar
      }
    ]

    essential = true
  }])

  tags = {
    Name        = "${var.repository_name}-task"
    Environment = "demo"
    ManagedBy   = "terraform"
  }

  depends_on = [null_resource.docker_build_push]
}

# Target Group for ALB
resource "aws_lb_target_group" "app" {
  name        = "${var.repository_name}-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.repository_name}-tg"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.repository_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.repository_name}-alb"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.repository_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.repository_name
    container_port   = 9000
  }

  tags = {
    Name        = "${var.repository_name}-service"
    Environment = "demo"
    ManagedBy   = "terraform"
  }

  depends_on = [aws_lb_listener.app]
}

