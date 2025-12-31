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
    server_hash     = filemd5("${path.module}/server.js")
    package_hash    = filemd5("${path.module}/package.json")
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

