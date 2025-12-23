#!/bin/bash
# Helper script to get ECS task public IP

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Getting ECS task public IP...${NC}\n"

# Get cluster and service from Terraform outputs
CLUSTER=$(terraform output -raw ecs_cluster_name 2>/dev/null)
if [ -z "$CLUSTER" ]; then
    echo -e "${RED}Error: Could not get cluster name from Terraform outputs${NC}"
    echo "Make sure you've run 'terraform apply' first"
    exit 1
fi

# Get AWS region from Terraform
REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")

echo "Cluster: $CLUSTER"
echo "Region: $REGION"
echo ""

# List tasks
TASK_ARN=$(aws ecs list-tasks \
    --cluster "$CLUSTER" \
    --region "$REGION" \
    --query 'taskArns[0]' \
    --output text)

if [ -z "$TASK_ARN" ] || [ "$TASK_ARN" = "None" ]; then
    echo -e "${RED}Error: No running tasks found${NC}"
    echo "Check that your ECS service has started tasks:"
    echo "  aws ecs describe-services --cluster $CLUSTER --services demo-app-service --region $REGION"
    exit 1
fi

echo "Task ARN: $TASK_ARN"
echo ""

# Get network interface ID
ENI_ID=$(aws ecs describe-tasks \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN" \
    --region "$REGION" \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

if [ -z "$ENI_ID" ]; then
    echo -e "${RED}Error: Could not get network interface ID${NC}"
    exit 1
fi

echo "Network Interface: $ENI_ID"
echo ""

# Get public IP
PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$ENI_ID" \
    --region "$REGION" \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo -e "${RED}Error: Task does not have a public IP${NC}"
    echo "Make sure assign_public_ip is set to true in the ECS service configuration"
    exit 1
fi

echo -e "${GREEN}✓ Success!${NC}\n"
echo "========================================"
echo "Task Public IP: $PUBLIC_IP"
echo "========================================"
echo ""
echo "Access your application at:"
echo -e "${GREEN}http://$PUBLIC_IP${NC}"
echo ""
echo "Test with curl:"
echo "  curl http://$PUBLIC_IP"
echo ""
echo -e "${YELLOW}Note: This IP will change if the task restarts${NC}"
