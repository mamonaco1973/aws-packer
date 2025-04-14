
Set-Location -Path "01-infrastructure"
terraform init
terraform destroy -auto-approve
Set-Location -Path ".."
