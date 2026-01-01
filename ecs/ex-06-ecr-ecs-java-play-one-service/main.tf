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
}

# Get default security group
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
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
  memory                   = "3072" # 3 GB
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

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.repository_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.repository_name}-service"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

