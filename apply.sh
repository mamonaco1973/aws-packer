#!/bin/bash

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

export AWS_DEFAULT_REGION="us-east-2"

# Step 1 - Build Infrastructure

echo "NOTE: Building networking infrastructure."

cd 01-infrastructure
terraform init
terraform apply -auto-approve
cd ..


# Step 2 - Build AMIS

vpc_id=$(aws ec2 describe-vpcs --region us-east-2 --filters "Name=tag:Name,Values=packer-vpc" --query "Vpcs[0].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --region us-east-2 --filters "Name=tag:Name,Values=packer-subnet-1" --query "Subnets[0].SubnetId" --output text)

#echo $vpc_id
#echo $subnet_id

cd 02-packer

cd linux
echo "NOTE: Building Linux AMI with Packer."
packer init ./linux_ami.pkr.hcl
packer build -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./linux_ami.pkr.hcl || { echo "NOTE: Packer build failed. Aborting."; exit 1; }
cd ..

cd ..





