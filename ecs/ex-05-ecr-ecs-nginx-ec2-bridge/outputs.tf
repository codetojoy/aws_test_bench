output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.demo.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.demo.arn
}

output "image_uri" {
  description = "Full URI of the pushed image"
  value       = "${aws_ecr_repository.demo.repository_url}:${var.image_tag}"
}

output "registry_id" {
  description = "Registry ID (AWS account ID)"
  value       = aws_ecr_repository.demo.registry_id
}

output "repository_name" {
  description = "Name of the repository"
  value       = var.repository_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "note" {
  description = "How to access your application"
  value       = "To get EC2 instance public IP, run: ./get-instance-ip.sh or use: aws ec2 describe-instances --filters 'Name=tag:Name,Values=${var.repository_name}-ecs-instance' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region ${var.aws_region}"
}
