#!/bin/bash

############################################
# STEP 0: ENVIRONMENT VALIDATION
############################################

# Execute the environment check script to ensure all preconditions are met
./check_env.sh

# If the script failed (non-zero exit code), abort the process immediately
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

############################################
# STEP 1: SET AWS DEFAULT REGION
############################################

# Set the AWS region for all subsequent CLI commands
export AWS_DEFAULT_REGION="us-east-2"

############################################
# STEP 2: TERRAFORM - BUILD NETWORKING INFRASTRUCTURE
############################################

# Inform user about infrastructure provisioning step
echo "NOTE: Building networking infrastructure."

# Navigate to the infrastructure provisioning folder
cd 01-infrastructure

# Initialize the Terraform backend and plugins
terraform init

# Apply the Terraform configuration non-interactively (auto-approve skips manual confirmation)
terraform apply -auto-approve

# Return to the root directory
cd ..

############################################
# STEP 3: BUILD AMIS WITH PACKER
############################################

# Retrieve the password for the Packer provisioning process from AWS Secrets Manager
password=$(aws secretsmanager get-secret-value \
  --secret-id packer-credentials \
  --query 'SecretString' \
  --output text | jq -r '.password')

# Validate that a non-empty password was successfully retrieved
if [[ -z "$password" || "$password" == "null" ]]; then
  echo "ERROR: Failed to retrieve password from secret 'packer-credentials'"
  exit 1
fi

# Extract the VPC ID of the VPC tagged as 'packer-vpc'
vpc_id=$(aws ec2 describe-vpcs \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=packer-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text)

# Extract the Subnet ID of the subnet tagged as 'packer-subnet-1'
subnet_id=$(aws ec2 describe-subnets \
  --region us-east-2 \
  --filters "Name=tag:Name,Values=packer-subnet-1" \
  --query "Subnets[0].SubnetId" \
  --output text)

# Move into the Packer configuration directory
cd 02-packer

############################################
# SUBSTEP: BUILD LINUX AMI
############################################

cd linux
echo "NOTE: Building Linux AMI with Packer."

# Initialize Packer to download necessary plugins and validate config
packer init ./linux_ami.pkr.hcl

# Execute the AMI build with injected variables for password, VPC, and Subnet
packer build -var "password=$password" -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./linux_ami.pkr.hcl || {
  echo "NOTE: Packer build failed. Aborting."
  exit 1
}

# Return to parent folder
cd ..

############################################
# SUBSTEP: BUILD WINDOWS AMI
############################################

cd windows
echo "NOTE: Building Windows AMI with Packer."

# Initialize Packer
packer init ./windows_ami.pkr.hcl

# Build the Windows AMI with same variables as above
packer build -var "password=$password" -var "vpc_id=$vpc_id" -var "subnet_id=$subnet_id" ./windows_ami.pkr.hcl || {
  echo "NOTE: Packer build failed. Aborting."
  exit 1
}

# Return to root directory
cd ../..

############################################
# STEP 4: TERRAFORM - DEPLOY EC2 INSTANCES
############################################

echo "NOTE: Deploying EC2 instances based on the AMIs"

# Enter the deployment folder
cd 03-deploy

# Initialize Terraform
terraform init

# Apply EC2 deployment Terraform code without prompting
terraform apply -auto-approve

# Return to project root
cd ..

############################################
# STEP 5: FETCH AND PRINT INSTANCE PUBLIC DNS NAMES
############################################

# Query AWS to get the public DNS name of the running Linux EC2 instance (tagged as games-ec2-instance)
linux_server=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=games-ec2-instance" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicDnsName" \
  --output text)

# Print access URL and DNS of the Linux server
echo "NOTE: Games URL is http://$linux_server"
echo "NOTE: Games server is $linux_server"

# Query AWS to get the public DNS name of the running Windows EC2 instance (tagged as desktop-ec2-instance)
windows_server=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=desktop-ec2-instance" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicDnsName" \
  --output text)

# Print the Windows server DNS name
echo "NOTE: Windows server is $windows_server"
