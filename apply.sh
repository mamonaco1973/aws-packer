#!/bin/bash

# ==============================================================================
# APPLY PIPELINE: BUILD AND DEPLOY ENVIRONMENT
# ==============================================================================
#
# This script performs an apply-only workflow to:
# - Validate the local execution environment
# - Provision networking infrastructure with Terraform
# - Build Linux and Windows AMIs using Packer
# - Deploy EC2 instances from the generated AMIs
# - Output public access details for deployed instances
#
# The script is intentionally one-directional and does not perform teardown.
# Execution stops immediately if any step fails.
# ==============================================================================

# ------------------------------------------------------------------------------
# Strict shell behavior
# ------------------------------------------------------------------------------
# -e         Exit immediately if any command fails
# -u         Treat unset variables as errors
# -o pipefail  Fail if any command in a pipeline fails
# ------------------------------------------------------------------------------
set -euo pipefail

# ==============================================================================
# STEP 0: ENVIRONMENT VALIDATION
# ==============================================================================
#
# Verify that required tools, credentials, and prerequisites are available
# before continuing with infrastructure changes.
# ==============================================================================

./check_env.sh

# ==============================================================================
# STEP 1: SET AWS DEFAULT REGION
# ==============================================================================
#
# Define the AWS region used by all subsequent AWS CLI, Terraform, and Packer
# operations executed by this script.
# ==============================================================================

export AWS_DEFAULT_REGION="us-east-2"

# ==============================================================================
# STEP 2: TERRAFORM APPLY - NETWORKING INFRASTRUCTURE
# ==============================================================================
#
# Provision base networking resources required for Packer builds and EC2
# deployments, including VPCs, subnets, and security groups.
# ==============================================================================

echo "NOTE: Applying networking infrastructure"

cd 01-infrastructure
terraform init
terraform apply -auto-approve
cd ..

# ==============================================================================
# STEP 3: BUILD AMIS WITH PACKER
# ==============================================================================
#
# Retrieve required secrets and identifiers, then build Linux and Windows AMIs
# using pre-defined Packer templates.
# ==============================================================================

# Retrieve the Packer provisioning password from AWS Secrets Manager
password=$(aws secretsmanager get-secret-value \
  --secret-id packer-credentials \
  --query 'SecretString' \
  --output text | jq -r '.password')

if [[ -z "$password" || "$password" == "null" ]]; then
  echo "ERROR: Failed to retrieve Packer password"
  exit 1
fi

# Resolve the VPC ID by Name tag
vpc_id=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=packer-vpc" \
  --query "Vpcs[0].VpcId" \
  --output text)

# Resolve the subnet ID by Name tag
subnet_id=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=packer-subnet-1" \
  --query "Subnets[0].SubnetId" \
  --output text)

cd 02-packer

# ------------------------------------------------------------------------------
# SUBSTEP: BUILD LINUX AMI
# ------------------------------------------------------------------------------

cd linux
echo "NOTE: Building Linux AMI"

packer init linux_ami.pkr.hcl
packer build \
  -var "password=$password" \
  -var "vpc_id=$vpc_id" \
  -var "subnet_id=$subnet_id" \
  linux_ami.pkr.hcl

cd ..

# ------------------------------------------------------------------------------
# SUBSTEP: BUILD WINDOWS AMI
# ------------------------------------------------------------------------------

cd windows
echo "NOTE: Building Windows AMI"

packer init windows_ami.pkr.hcl
packer build \
  -var "password=$password" \
  -var "vpc_id=$vpc_id" \
  -var "subnet_id=$subnet_id" \
  windows_ami.pkr.hcl

cd ../..

# ==============================================================================
# STEP 4: TERRAFORM APPLY - EC2 DEPLOYMENT
# ==============================================================================
#
# Deploy EC2 instances using the most recently built AMIs.
# ==============================================================================

echo "NOTE: Deploying EC2 instances"

cd 03-deploy
terraform init
terraform apply -auto-approve
cd ..

# ==============================================================================
# STEP 5: VALIDATE THE BUILD.
# ==============================================================================

./validate.sh