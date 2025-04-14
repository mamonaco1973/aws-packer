
# First phase - Build all the infrastructure with 0 autoscaling instances and a generic AMI

Set-Location -Path "01-infrastructure"
Write-Output "NOTE: Building infrastructure phase 1."
terraform init
terraform apply -var="asg_instances=0" -auto-approve
Set-Location -Path ".."
