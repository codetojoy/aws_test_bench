terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
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

# ECR authorization token
data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
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

# Create a simple Dockerfile
resource "local_file" "dockerfile" {
  content  = <<-EOF
    FROM nginx:alpine
    RUN echo '<h1>Hello from ECR Demo!</h1>' > /usr/share/nginx/html/index.html
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]
  EOF
  filename = "${path.module}/Dockerfile"
}

# Build Docker image
resource "docker_image" "demo" {
  name = "${aws_ecr_repository.demo.repository_url}:${var.image_tag}"

  build {
    context    = path.module
    dockerfile = "Dockerfile"
    platform   = "linux/amd64" # Force amd64 architecture for Fargate
  }

  depends_on = [local_file.dockerfile]
}

# Push image to ECR
resource "docker_registry_image" "demo" {
  name = docker_image.demo.name

  depends_on = [docker_image.demo]
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

# ===================================
# ECS Deployment Configuration
# ===================================

# Create VPC for ECS (minimal setup)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.repository_name}-vpc"
  }
}

# Public subnets for ECS tasks
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.repository_name}-public-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.repository_name}-igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.repository_name}-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.repository_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled" # Minimal resources - disable insights
  }

  tags = {
    Name = "${var.repository_name}-cluster"
  }
}

# Auto Scaling Group for ECS EC2 instances
resource "aws_autoscaling_group" "ecs" {
  name                      = "${var.repository_name}-ecs-asg"
  vpc_zone_identifier       = aws_subnet.public[*].id
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.repository_name}-ecs-instance"
    propagate_at_launch = true
  }
}

# Get latest ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Launch Template for ECS EC2 instances
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.repository_name}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
    echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
  EOF
  )

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.repository_name}-ecs-instance"
    }
  }
}

# IAM role for EC2 instances
resource "aws_iam_role" "ecs_instance" {
  name = "${var.repository_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.repository_name}-ecs-instance-role"
  }
}

# Attach ECS policy to instance role
resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# IAM instance profile
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.repository_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}

# Security group for EC2 instances
resource "aws_security_group" "ecs_instances" {
  name        = "${var.repository_name}-ecs-instances-sg"
  description = "Security group for ECS EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow dynamic port mapping from anywhere"
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.repository_name}-ecs-instances-sg"
  }
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.repository_name}"
  retention_in_days = 7 # Minimal retention

  tags = {
    Name = "${var.repository_name}-logs"
  }
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution" {
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
    Name = "${var.repository_name}-ecs-task-execution-role"
  }
}

# Attach the Amazon ECS task execution role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role for ECS task (application role)
resource "aws_iam_role" "ecs_task" {
  name = "${var.repository_name}-ecs-task-role"

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
    Name = "${var.repository_name}-ecs-task-role"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.repository_name
  network_mode             = "bridge" # EC2 requires bridge mode
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  # Note: CPU and memory are at the container level for EC2, not task level
  container_definitions = jsonencode([{
    name      = var.repository_name
    image     = "${aws_ecr_repository.demo.repository_url}:${var.image_tag}"
    cpu       = var.ecs_container_cpu
    memory    = var.ecs_container_memory
    essential = true

    portMappings = [{
      containerPort = 80
      hostPort      = 0 # Dynamic port mapping
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }

    environment = []
  }])

  depends_on = [docker_registry_image.demo]

  tags = {
    Name = "${var.repository_name}-task-def"
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.repository_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "EC2"

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution,
    aws_autoscaling_group.ecs
  ]

  tags = {
    Name = "${var.repository_name}-service"
  }
}
