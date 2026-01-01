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

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 3
}

variable "application_secret" {
  description = "Application secret key for Play Framework"
  type        = string
  sensitive   = true
  default     = "default"
}

variable "my_foobar" {
  description = "Custom environment variable for demonstration"
  type        = string
  default     = "default"
}

