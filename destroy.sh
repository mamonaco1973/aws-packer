#!/bin/bash

############################################
# SET DEFAULT AWS REGION
############################################

# Export the AWS region to ensure all AWS CLI commands run in the correct context
export AWS_DEFAULT_REGION="us-east-2"

############################################
# STEP 1: DESTROY EC2 INSTANCES (03-deploy)
############################################

# Navigate into the Terraform directory for EC2 deployment
cd 03-deploy

# Initialize Terraform backend and provider plugins (safe for destroy)
terraform init

# Destroy all EC2 instances and related resources provisioned by Terraform
terraform destroy -auto-approve  # Auto-approve skips manual confirmation prompts

# Return to root directory after EC2 teardown
cd ..

############################################
# STEP 2: CLEANUP - DELETE ALL GAMES AMIS & SNAPSHOTS
############################################

# Loop through all AMIs named like 'games_ami*' owned by this AWS account
for ami_id in $(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=games_ami*" \
    --query "Images[].ImageId" \
    --output text); do

    # For each AMI, find associated EBS snapshot IDs
    for snapshot_id in $(aws ec2 describe-images \
        --image-ids $ami_id \
        --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" \
        --output text); do

        # Log deregistration and snapshot deletion
        echo "Deregistering AMI: $ami_id"
        aws ec2 deregister-image --image-id $ami_id

        echo "Deleting snapshot: $snapshot_id"
        aws ec2 delete-snapshot --snapshot-id $snapshot_id
    done
done

############################################
# STEP 3: CLEANUP - DELETE ALL DESKTOP AMIS & SNAPSHOTS
############################################

# Repeat same logic for AMIs named 'desktop_ami*'
for ami_id in $(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=desktop_ami*" \
    --query "Images[].ImageId" \
    --output text); do

    for snapshot_id in $(aws ec2 describe-images \
        --image-ids $ami_id \
        --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" \
        --output text); do

        echo "Deregistering AMI: $ami_id"
        aws ec2 deregister-image --image-id $ami_id

        echo "Deleting snapshot: $snapshot_id"
        aws ec2 delete-snapshot --snapshot-id $snapshot_id
    done
done

############################################
# STEP 4: DELETE SECRET - PACKER PASSWORD
############################################

# Permanently delete the secret used for AMI builds (no recovery option!)
aws secretsmanager delete-secret \
  --secret-id "packer-credentials" \
  --force-delete-without-recovery

############################################
# STEP 5: DESTROY INFRASTRUCTURE (01-infrastructure)
############################################

# Navigate into the networking infrastructure folder
cd 01-infrastructure

# Reinitialize Terraform backend
terraform init

# Destroy all VPC, subnet, and security group resources provisioned earlier
terraform destroy -auto-approve

# Return to project root
cd ..
