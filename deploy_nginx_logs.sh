#!/bin/bash

# Set variables
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(terraform output -raw ecs_service_name)
REGION=$(terraform output -raw aws_region)

# Check if variables are set
if [ -z "$CLUSTER_NAME" ] || [ -z "$SERVICE_NAME" ] || [ -z "$REGION" ]; then
    echo "Error: Couldn't retrieve cluster name, service name, or region from Terraform output."
    exit 1
fi

echo "Using Cluster: $CLUSTER_NAME"
echo "Using Service: $SERVICE_NAME"
echo "Using Region: $REGION"

# Get the task ID
TASK_ID=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --region $REGION --query 'taskArns[0]' --output text | awk -F '/' '{print $3}')

if [ -z "$TASK_ID" ]; then
    echo "Error: No running tasks found for the service."
    exit 1
fi

echo "Task ID: $TASK_ID"

# Check if collect_nginx_logs.sh exists in the current directory
if [ ! -f "collect_nginx_logs.sh" ]; then
    echo "Error: collect_nginx_logs.sh not found in the current directory."
    exit 1
fi

# Copy the script to the container
echo "Copying script to container..."
aws ecs execute-command --cluster $CLUSTER_NAME \
    --task $TASK_ID \
    --container nginx-container \
    --command "/bin/sh -c 'cat > /tmp/collect_nginx_logs.sh'" \
    --interactive < collect_nginx_logs.sh

# Make the script executable
echo "Making script executable..."
aws ecs execute-command --cluster $CLUSTER_NAME \
    --task $TASK_ID \
    --container nginx-container \
    --command "chmod +x /tmp/collect_nginx_logs.sh" \
    --interactive

# Run the script
echo "Running the script..."
aws ecs execute-command --cluster $CLUSTER_NAME \
    --task $TASK_ID \
    --container nginx-container \
    --command "/tmp/collect_nginx_logs.sh &" \
    --interactive

echo "Script execution completed."