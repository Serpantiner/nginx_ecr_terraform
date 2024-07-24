#!/bin/bash

# Set the region
REGION="us-west-2"

# Get the TASK ARN
TASK_ARN=$(aws ecs list-tasks --cluster $(terraform output -raw ecs_cluster_name) --service-name $(terraform output -raw ecs_service_name) --query 'taskArns[0]' --output text --region $REGION)

# Get the ENI ID
ENI_ID=$(aws ecs describe-tasks --cluster $(terraform output -raw ecs_cluster_name) --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text --region $REGION)

# Get the public IP
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Association.PublicIp' --output text --region $REGION)

echo "Your Nginx server is available at: http://$PUBLIC_IP"
