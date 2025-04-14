
# Second phase - Run the packer build to build the application after we have a network

Set-Location -Path "02-packer"
Write-Output "NOTE: Building AMI with packer."
$vpc_id = (aws ec2 describe-vpcs --region us-east-2 --filters "Name=tag:Name,Values=flask-vpc" --query "Vpcs[0].VpcId" --output text)
$subnet_id = (aws ec2 describe-subnets --region us-east-2 --filters "Name=tag:Name,Values=flask-subnet-1" --query "Subnets[0].SubnetId" --output text)

if (-not $vpc_id -or $vpc_id -eq "None") {
    Write-Error "ERROR: VPC 'flask-vpc' could not be retrieved. Please ensure the VPC exists and is tagged correctly."
    exit 1
}

if (-not $subnet_id -or $subnet_id -eq "None") {
    Write-Error "ERROR: Subnet 'flask-subnet-1' could not be retrieved. Please ensure the subnet exists and is tagged correctly."
    exit 1
}

packer init ./flask_ami.pkr.hcl
packer build -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./flask_ami.pkr.hcl
if (!$?) {
    Write-Error "NOTE: Packer build failed. Aborting."
    exit 1
}
Set-Location -Path ".."
