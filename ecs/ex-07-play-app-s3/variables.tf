variable "aws_region" {
  description = "AWS region for ECR repository"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "test-bench-ecr-ex-07"
}

variable "image_tag" {
  description = "Tag for the Docker image"
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
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

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for file storage"
  type        = string
  default     = "test-bench-bucket-ex07"
}

variable "ssm_secret_value" {
  description = "Value for the SSM secret parameter"
  type        = string
  sensitive   = true
  default     = "default-secret-value"
}

