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

variable "ec2_instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
  default     = "t3.micro"
}

variable "ecs_container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "ecs_container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}
