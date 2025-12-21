# Deployment Guide

## Pre-Deployment Checklist

- [ ] Docker Desktop is running
- [ ] AWS CLI is configured (`aws sts get-caller-identity`)
- [ ] You have sufficient AWS permissions (ECR, ECS, VPC, IAM)
- [ ] Terraform is installed (`terraform version`)
- [ ] You're in the correct AWS region

## Step-by-Step Deployment

### 1. Initialize Terraform
```bash
terraform init
```
Expected output: "Terraform has been successfully initialized!"

### 2. Validate Configuration
```bash
terraform validate
```
This checks for syntax errors.

### 3. Plan Deployment
```bash
terraform plan -out=tfplan
```
Review the plan carefully. You should see ~25+ resources to be created.

### 4. Apply Configuration
```bash
terraform apply tfplan
```
Wait 2-3 minutes for deployment to complete.

### 5. Get Task Public IP
```bash
# Use the helper script
./get-task-ip.sh

# Or manually
CLUSTER=$(terraform output -raw ecs_cluster_name)
TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER --region us-east-1 --query 'taskArns[0]' --output text)
ENI_ID=$(aws ecs describe-tasks --cluster $CLUSTER --tasks $TASK_ARN --region us-east-1 --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region us-east-1 --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
echo "Access your app at: http://$PUBLIC_IP"
```

### 6. Verify Deployment
```bash
# Test the application
curl http://$PUBLIC_IP
```

## Updating Your Application

### 1. Modify the Dockerfile
Edit the generated `Dockerfile` or create your own.

### 2. Rebuild and Push
```bash
# Increment the version tag
terraform apply -var="image_tag=v1.0.1"
```

### 3. Force New Deployment
```bash
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service $(terraform output -raw ecs_service_name) \
  --force-new-deployment \
  --region us-east-1
```

## Scaling Your Application

### Manual Scaling
```bash
# Scale up to 3 tasks
terraform apply -var="ecs_desired_count=3"

# Or use AWS CLI
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service $(terraform output -raw ecs_service_name) \
  --desired-count 3 \
  --region us-east-1
```

### Auto-Scaling (Add to main.tf)
```hcl
# Auto-scaling target
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Scale based on CPU
resource "aws_appautoscaling_policy" "cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 75.0
  }
}
```

## Monitoring and Debugging

### Get Task Public IP (Quick)
```bash
# Use the helper script
./get-task-ip.sh
```

### View Logs
```bash
# Stream logs in real-time
aws logs tail /ecs/demo-app --follow --region us-east-1

# View recent logs
aws logs tail /ecs/demo-app --since 1h --region us-east-1
```

### Check Task Status
```bash
# List tasks
aws ecs list-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --region us-east-1

# Describe specific task
TASK_ARN=$(aws ecs list-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --region us-east-1 \
  --query 'taskArns[0]' \
  --output text)

aws ecs describe-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --tasks $TASK_ARN \
  --region us-east-1
```

### Execute Commands in Running Container
```bash
# First, enable ECS Exec in the task definition (add to main.tf):
# enable_execute_command = true

# Then connect to container
aws ecs execute-command \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --task $TASK_ARN \
  --container demo-app \
  --interactive \
  --command "/bin/sh"
```

## Common Issues and Solutions

### Issue: Tasks keep restarting
**Symptoms**: Service shows "service is unable to consistently start tasks"

**Solutions**:
1. Check logs: `aws logs tail /ecs/demo-app --follow`
2. Verify image exists in ECR: `aws ecr describe-images --repository-name demo-app`
3. Check task definition is valid
4. Ensure security groups allow traffic

### Issue: Cannot access task via public IP
**Symptoms**: Connection timeout or refused

**Solutions**:
1. Wait 1-2 minutes after task starts
2. Verify task has a public IP: `./get-task-ip.sh`
3. Check security group allows port 80 from 0.0.0.0/0
4. Ensure task is in a public subnet with Internet Gateway route
5. Verify task is in RUNNING state

### Issue: Task has no public IP
**Symptoms**: get-task-ip.sh returns "None"

**Solutions**:
1. Check `assign_public_ip = true` in ECS service network configuration
2. Verify tasks are in public subnets (not private)
3. Restart the service: `terraform apply`

### Issue: High costs
**Symptoms**: Unexpected AWS bills

**Solutions**:
1. Stop tasks when not needed: `terraform apply -var="ecs_desired_count=0"`
2. Use Fargate Spot for 70% savings (modify main.tf)
3. Delete resources when done: `terraform destroy`

### Issue: Deployment is slow
**Symptoms**: `terraform apply` takes >5 minutes

**Causes**:
- ECS service deployment takes 2-3 minutes
- Normal for first deployment

## Cost Optimization Tips

1. **Use Fargate Spot** for ~70% savings:
   ```hcl
   # In main.tf, modify the ECS service:
   resource "aws_ecs_service" "main" {
     # Remove: launch_type = "FARGATE"
     # Add:
     capacity_provider_strategy {
       capacity_provider = "FARGATE_SPOT"
       weight            = 100
       base              = 0
     }
   }
   ```

2. **Scheduled Scaling**:
   - Scale down to 0 during off-hours
   - Use EventBridge + Lambda to automate

3. **Right-size Resources**:
   - Monitor CloudWatch metrics
   - Adjust CPU/memory based on actual usage

4. **Stop when not needed**:
   ```bash
   # Stop tasks
   terraform apply -var="ecs_desired_count=0"
   
   # Resume
   terraform apply -var="ecs_desired_count=1"
   ```

## Adding a Load Balancer (Optional)

For production use, you may want to add an Application Load Balancer for:
- Stable DNS name
- Automatic health checks
- SSL/TLS termination
- Multiple availability zones

To add an ALB, you would need to:
1. Create `aws_lb` resource
2. Create `aws_lb_target_group` resource
3. Create `aws_lb_listener` resource
4. Add load_balancer block to ECS service
5. Move tasks back to private subnets
6. Add NAT Gateway for private subnet internet access

See the git history or AWS documentation for examples.

## Security Best Practices

1. **Restrict Security Groups**:
   ```hcl
   # Instead of 0.0.0.0/0, limit to your IP
   ingress {
     description = "HTTP from my IP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["YOUR.IP.ADDRESS/32"]
   }
   ```

2. **Use Secrets Manager** for sensitive data:
   ```hcl
   secrets = [{
     name      = "DB_PASSWORD"
     valueFrom = aws_secretsmanager_secret.db_password.arn
   }]
   ```

3. **Enable HTTPS** (requires ALB):
   - Request ACM certificate
   - Add HTTPS listener to ALB
   - Redirect HTTP to HTTPS

4. **Enable VPC Flow Logs**:
   - Monitor network traffic
   - Detect anomalies

5. **Use IAM roles** (already implemented):
   - Never use access keys in containers
   - Grant minimal required permissions

## Production Readiness Checklist

- [ ] Load balancer configured for stable access
- [ ] HTTPS configured with ACM certificate
- [ ] Custom domain configured with Route53
- [ ] Auto-scaling configured
- [ ] CloudWatch alarms set up
- [ ] Backup strategy defined
- [ ] Disaster recovery plan
- [ ] Security groups hardened (not 0.0.0.0/0)
- [ ] Secrets stored in Secrets Manager
- [ ] Container image scanning enabled
- [ ] Log aggregation configured
- [ ] Monitoring dashboard created
- [ ] Cost alerts configured
- [ ] Tasks in private subnets (if using ALB)
