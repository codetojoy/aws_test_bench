# AWS Concepts Used in This Demo Project

This document summarizes the AWS services and concepts used in this ECS demo project.

## Amazon ECR (Elastic Container Registry)

**What it is:** A fully-managed Docker container registry that makes it easy to store, manage, and deploy Docker container images.

**How we use it:**
- Store the Docker image for our Play Framework application
- Image scanning on push for security vulnerabilities
- Lifecycle policy to keep only the last 5 images

**Key resources:**
- `aws_ecr_repository.demo` - The container registry
- Image URI format: `{account-id}.dkr.ecr.{region}.amazonaws.com/{repository-name}:{tag}`

## Amazon ECS (Elastic Container Service)

**What it is:** A container orchestration service that runs and manages Docker containers on a cluster.

**How we use it:**
- Run our containerized Play Framework application
- Manage multiple instances (tasks) of the application
- Auto-scaling and load distribution

**Key components:**

### ECS Cluster
- Logical grouping of tasks and services
- `aws_ecs_cluster.main` - Our cluster named `{repository-name}-cluster`

### Task Definition
- Blueprint for running containers
- Specifies: Docker image, CPU/memory, environment variables, port mappings
- `aws_ecs_task_definition.app` - Defines our container configuration
  - 0.5 vCPU (512 CPU units)
  - 1 GB memory (1024 MB)
  - Environment variables: `APPLICATION_SECRET`, `MY_FOOBAR`
  - Port 9000 exposed

### ECS Service
- Manages running tasks based on task definition
- Ensures desired number of tasks are running
- Integrates with load balancer for traffic distribution
- `aws_ecs_service.app` - Runs 3 instances of our application

## AWS Fargate

**What it is:** A serverless compute engine for containers that removes the need to provision and manage servers.

**How we use it:**
- Launch type for our ECS tasks
- No EC2 instances to manage
- Pay only for the resources used by running containers
- Network mode: `awsvpc` (each task gets its own ENI and private IP)

**Benefits:**
- No server management
- Automatic scaling
- Isolation by design

## Application Load Balancer (ALB)

**What it is:** A Layer 7 (HTTP/HTTPS) load balancer that distributes incoming traffic across multiple targets.

**How we use it:**
- Distribute HTTP traffic across 3 ECS tasks
- Public-facing endpoint for our application
- Health checks to ensure only healthy tasks receive traffic

**Key resources:**
- `aws_lb.app` - The load balancer itself
- `aws_lb_target_group.app` - Defines targets (ECS tasks on port 9000)
- `aws_lb_listener.app` - Listens on port 80, forwards to target group

**Traffic flow:**
```
Internet (port 80)
  → ALB (port 80)
    → Target Group
      → ECS Tasks (port 9000)
```

## VPC (Virtual Private Cloud)

**What it is:** An isolated virtual network in AWS where you can launch resources.

**How we use it:**
- Using the default VPC
- Default subnets across multiple Availability Zones
- `data.aws_vpc.default` - References the default VPC
- `data.aws_subnets.default` - Gets default subnets (one per AZ)

**Important:**
- The subnet filter `default-for-az = "true"` ensures we get exactly one subnet per Availability Zone
- ALB requires subnets in at least 2 AZs, but only one subnet per AZ

## Security Groups

**What they are:** Virtual firewalls that control inbound and outbound traffic.

**How we use them:**

### ALB Security Group (`aws_security_group.alb`)
- **Ingress:** Allow HTTP (port 80) from anywhere (0.0.0.0/0)
- **Egress:** Allow all outbound traffic
- Protects the load balancer

### ECS Tasks Security Group (`aws_security_group.ecs_tasks`)
- **Ingress:** Allow traffic on port 9000 ONLY from ALB security group
- **Egress:** Allow all outbound traffic
- Protects the ECS tasks
- Implements least-privilege access (only ALB can reach tasks)

**Security principle:** Defense in depth - only the ALB is publicly accessible; tasks are protected

## IAM (Identity and Access Management)

**What it is:** Controls access to AWS services and resources.

**How we use it:**

### Task Execution Role (`aws_iam_role.ecs_task_execution_role`)
- Allows ECS to perform actions on your behalf
- Pull images from ECR
- Write logs to CloudWatch (if enabled)
- Uses AWS managed policy: `AmazonECSTaskExecutionRolePolicy`

**Trust policy:** Allows `ecs-tasks.amazonaws.com` service to assume this role

## Terraform Concepts Used

### Data Sources
- Read-only queries to existing AWS resources
- Examples: `data.aws_vpc.default`, `data.aws_caller_identity.current`

### Resources
- Create and manage AWS infrastructure
- Examples: `aws_ecr_repository`, `aws_ecs_cluster`, `aws_lb`

### Variables
- Parameterize configuration
- Examples: `aws_region`, `repository_name`, `desired_count`, `application_secret`

### Outputs
- Export values for external use
- Examples: `alb_url`, `repository_url`, `ecs_cluster_name`

### Null Resource with Local-Exec
- `null_resource.docker_build_push` - Runs local commands (Docker build/push)
- Triggers on file changes (Dockerfile, JAR file)

## Architecture Diagram (Conceptual)

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP (port 80)
                            ▼
                ┌───────────────────────┐
                │  Application Load     │
                │  Balancer (ALB)       │
                │  Security Group: ALB  │
                └───────────┬───────────┘
                            │ HTTP (port 9000)
                            ▼
                ┌───────────────────────┐
                │   Target Group        │
                │   Health Checks       │
                └───────────┬───────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  ECS Task 1  │    │  ECS Task 2  │    │  ECS Task 3  │
│  Fargate     │    │  Fargate     │    │  Fargate     │
│  Port 9000   │    │  Port 9000   │    │  Port 9000   │
│  SG: Tasks   │    │  SG: Tasks   │    │  SG: Tasks   │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       └───────────────────┴───────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │     ECR     │
                    │ (pulls image)│
                    └─────────────┘
```

## Key AWS Concepts Summary

1. **Container Registry (ECR):** Store Docker images
2. **Container Orchestration (ECS):** Run and manage containers
3. **Serverless Compute (Fargate):** No server management
4. **Load Balancing (ALB):** Distribute traffic
5. **Networking (VPC, Subnets):** Network isolation
6. **Security (Security Groups):** Control traffic
7. **Identity (IAM):** Control access and permissions

## Cost Considerations

**What you pay for in this demo:**
- ECR storage (minimal for one image)
- Fargate vCPU and memory per hour (3 tasks × 0.5 vCPU × 1 GB)
- ALB per hour + data processed
- Data transfer out to internet

**Cost optimization tips:**
- Reduce `desired_count` to 1 for testing
- Destroy resources when not in use (`terraform destroy`)
- Use smaller task sizes if application allows
