
# Third phase - Re-run infrastructure code with the application AMI and two instances spread across to two AZs

Set-Location -Path "01-infrastructure"
$ami_id = (aws ec2 describe-images --region us-east-2 --filters "Name=name,Values=flask_server_ami*" "Name=state,Values=available" --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" --output text)

if (-not $ami_id -or $ami_id -eq "None") {
    Write-Error "ERROR: AMI ID could not be retrieved. Please ensure the AMI exists and matches the specified filters."
    exit 1
}

Write-Output "NOTE: Using AMI ID: $ami_id"
Write-Output "NOTE: Building infrastructure phase 3."
terraform init
terraform apply -var="default_ami=$ami_id" -var="asg_instances=2" -auto-approve
Set-Location -Path ".."
