#!/bin/bash

# ==============================================================================
# DESTROY PIPELINE: TEARDOWN AND CLEANUP
# ==============================================================================
#
# This script performs a full teardown of resources created by the apply
# pipeline. It destroys EC2 deployments, deregisters custom AMIs, deletes
# associated snapshots, removes secrets, and tears down networking.
#
# WARNING:
# - This script is destructive and irreversible.
# - All matching AMIs, snapshots, and infrastructure will be removed.
# - Use only in non-production or controlled environments.
# ==============================================================================

# ==============================================================================
# SET DEFAULT AWS REGION
# ==============================================================================
#
# Export the AWS region to ensure all AWS CLI commands run in the intended
# account and regional context.
# ==============================================================================

export AWS_DEFAULT_REGION="us-east-2"

# ==============================================================================
# STEP 1: DESTROY EC2 DEPLOYMENT (03-deploy)
# ==============================================================================
#
# Tear down EC2 instances and related resources managed by Terraform in the
# deployment layer.
# ==============================================================================

cd 03-deploy

# Initialize Terraform backend and providers before destroy.
terraform init

# Destroy all EC2 resources without interactive confirmation.
terraform destroy -auto-approve

# Return to project root.
cd ..

# ==============================================================================
# STEP 2: CLEANUP GAMES AMIS AND SNAPSHOTS
# ==============================================================================
#
# Deregister all custom AMIs matching the "games_ami*" naming convention and
# delete their associated EBS snapshots.
# ==============================================================================

for ami_id in $(aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=games_ami*" \
  --query "Images[].ImageId" \
  --output text); do

  # Retrieve snapshot IDs associated with the AMI.
  for snapshot_id in $(aws ec2 describe-images \
    --image-ids "$ami_id" \
    --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" \
    --output text); do

    echo "NOTE: Deregistering AMI: $ami_id"
    aws ec2 deregister-image --image-id "$ami_id"

    echo "NOTE: Deleting snapshot: $snapshot_id"
    aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
  done
done

# ==============================================================================
# STEP 3: CLEANUP DESKTOP AMIS AND SNAPSHOTS
# ==============================================================================
#
# Repeat the cleanup process for desktop AMIs matching "desktop_ami*".
# ==============================================================================

for ami_id in $(aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=desktop_ami*" \
  --query "Images[].ImageId" \
  --output text); do

  for snapshot_id in $(aws ec2 describe-images \
    --image-ids "$ami_id" \
    --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" \
    --output text); do

    echo "NOTE: Deregistering AMI: $ami_id"
    aws ec2 deregister-image --image-id "$ami_id"

    echo "NOTE: Deleting snapshot: $snapshot_id"
    aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
  done
done

# ==============================================================================
# STEP 4: DELETE PACKER CREDENTIAL SECRET
# ==============================================================================
#
# Permanently delete the Secrets Manager entry used during Packer builds.
# The secret is removed without a recovery window.
# ==============================================================================

aws secretsmanager delete-secret \
  --secret-id "packer-credentials" \
  --force-delete-without-recovery

# ==============================================================================
# STEP 5: DESTROY NETWORKING INFRASTRUCTURE (01-infrastructure)
# ==============================================================================
#
# Tear down the base networking resources including VPCs, subnets, route
# tables, and security groups created for the build environment.
# ==============================================================================

cd 01-infrastructure

# Initialize Terraform backend and providers before destroy.
terraform init

# Destroy all networking resources without interactive confirmation.
terraform destroy -auto-approve

# Return to project root.
cd ..
