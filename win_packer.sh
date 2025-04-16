#!/bin/bash

# Extract password from AWS Secrets Manager
password=$(aws secretsmanager get-secret-value \
  --secret-id packer-credentials \
  --query 'SecretString' \
  --output text | jq -r '.password')

# Check if the password is empty or null
if [[ -z "$password" || "$password" == "null" ]]; then
  echo "ERROR: Failed to retrieve password from secret 'packer-credentials'"
  exit 1
fi

vpc_id=$(aws ec2 describe-vpcs --region us-east-2 --filters "Name=tag:Name,Values=packer-vpc" --query "Vpcs[0].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --region us-east-2 --filters "Name=tag:Name,Values=packer-subnet-1" --query "Subnets[0].SubnetId" --output text)

cd 02-packer

cd windows
echo "NOTE: Building Windows AMI with Packer."
packer init ./windows_ami.pkr.hcl
packer build -var "password=$password" -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./windows_ami.pkr.hcl || { echo "NOTE: Packer build failed. Aborting."; exit 1; }
cd ..

cd ..

