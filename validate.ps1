# Configuration
$TARGET_GROUP_NAME = "flask-alb-tg"
$MAX_WAIT_TIME = 300 # 5 minutes in seconds
$INTERVAL = 10       # Check every 10 seconds

# Fetch the Target Group ARN
$TARGET_GROUP_ARN = (aws elbv2 describe-target-groups --names $TARGET_GROUP_NAME --query 'TargetGroups[0].TargetGroupArn' --output text)

if (-not $TARGET_GROUP_ARN) {
    Write-Host "ERROR: Target group $TARGET_GROUP_NAME not found."
    exit 1
}

# Start checking for healthy targets
$START_TIME = Get-Date

Write-Host "NOTE: Checking for healthy targets in target group $TARGET_GROUP_NAME."

while ($true) {
    # Check for healthy targets
    $HEALTHY_TARGETS = (aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN `
        --query 'TargetHealthDescriptions[?TargetHealth.State==`"healthy`"].Target.Id' --output text)

    if ($HEALTHY_TARGETS) {
        Write-Host "NOTE: Healthy targets found on $TARGET_GROUP_NAME."
        
        $dns_name = (aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='flask-alb'].DNSName" --output text)
        Write-Host "NOTE: URL for EC2 Solution is http://$dns_name/gtg?details=true"

        # Execute the test script

        .\build\test_candidates.ps1 $dns_name

        exit 0
    }

    # Check if the maximum wait time has been exceeded
    $CURRENT_TIME = Get-Date
    $ELAPSED_TIME = ($CURRENT_TIME - $START_TIME).TotalSeconds

    if ($ELAPSED_TIME -ge $MAX_WAIT_TIME) {
        Write-Host "ERROR: No healthy targets found within $MAX_WAIT_TIME seconds."
        exit 1
    }

    # Wait for the interval before checking again
    Start-Sleep -Seconds $INTERVAL
}
