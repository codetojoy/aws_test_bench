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

