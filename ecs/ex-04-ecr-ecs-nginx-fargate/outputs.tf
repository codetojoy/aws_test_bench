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
  value       = "To get task public IPs, run: aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --region ${var.aws_region} and then describe-tasks to get network details"
}
