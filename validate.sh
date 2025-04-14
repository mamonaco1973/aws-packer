#!/bin/bash

# Configuration
TARGET_GROUP_NAME="flask-alb-tg"
MAX_WAIT_TIME=300 # 5 minutes in seconds
INTERVAL=10       # Check every 10 seconds

# Fetch the Target Group ARN
TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups --names "$TARGET_GROUP_NAME" --query 'TargetGroups[0].TargetGroupArn' --output text)

if [ -z "$TARGET_GROUP_ARN" ]; then
    echo "ERROR: Target group $TARGET_GROUP_NAME not found."
    exit 1
fi

# Start checking for healthy targets
START_TIME=$(date +%s)

echo "NOTE: Checking for healthy targets in target group $TARGET_GROUP_NAME."

while true; do
    # Check for healthy targets
    HEALTHY_TARGETS=$(aws elbv2 describe-target-health --target-group-arn "$TARGET_GROUP_ARN" \
        --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`].Target.Id' --output text)

    if [ -n "$HEALTHY_TARGETS" ]; then
        echo "NOTE: Healthy targets found on $TARGET_GROUP_NAME."
        cd ./02-packer/scripts # Navigate to the test scripts directory.
        echo "NOTE: Testing the EC2 Solution"

        dns_name=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='flask-alb'].DNSName" --output text) 
        echo "NOTE: URL for EC2 Solution is http://$dns_name/gtg?details=true"

        ./test_candidates.py $dns_name                                                                                            

        cd ..
        cd ..

        exit 0
    fi

    # Check if the maximum wait time has been exceeded
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

    if [ "$ELAPSED_TIME" -ge "$MAX_WAIT_TIME" ]; then
        echo "ERROR: No healthy targets found within $MAX_WAIT_TIME seconds."
        exit 1
    fi

    # Wait for the interval before checking again
    sleep "$INTERVAL"
done
