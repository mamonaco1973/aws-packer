#!/bin/bash

# Second phase - Run the packer build to build the application after we have a network

cd 02-packer
echo "NOTE: Building AMI with packer."
vpc_id=$(aws ec2 describe-vpcs --region us-east-2 --filters "Name=tag:Name,Values=flask-vpc" --query "Vpcs[0].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --region us-east-2 --filters "Name=tag:Name,Values=flask-subnet-1" --query "Subnets[0].SubnetId" --output text)

# Check if vpc_id or subnet_id is empty or contains "None"
if [ -z "$vpc_id" ] || [ "$vpc_id" == "None" ]; then
  echo "ERROR: VPC 'flask-vpc' could not be retrieved. Please ensure the VPC exists and is tagged correctly."
  exit 1
fi

if [ -z "$subnet_id" ] || [ "$subnet_id" == "None" ]; then
  echo "ERROR: Subnet 'flask-subnet-1' could not be retrieved. Please ensure the subnet exists and is tagged correctly."
  exit 1
fi

packer init ./flask_ami.pkr.hcl
packer build -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./flask_ami.pkr.hcl || { echo "NOTE: Packer build failed. Aborting."; exit 1; }
cd ..
