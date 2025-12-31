variable "aws_region" {
  description = "AWS region for ECR repository"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "demo-app"
}

variable "image_tag" {
  description = "Tag for the Docker image"
  type        = string
  default     = "latest"
}

