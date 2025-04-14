#!/bin/bash
# Fetch AMIs with names starting with "flask_server_ami"
for ami_id in $(aws ec2 describe-images \
    --owners self \
    --region us-east-2 \
    --filters "Name=name,Values=flask_server_ami*" \
    --query "Images[].ImageId" \
    --output text); do

    # Fetch and delete associated snapshots
    for snapshot_id in $(aws ec2 describe-images \
        --image-ids $ami_id \
        --region us-east-2 \
        --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" \
        --output text); do
	echo "NOTE: Deregistering AMI: $ami_id"
	aws ec2 deregister-image --image-id $ami_id
        echo "NOTE: Deleting snapshot: $snapshot_id"
        aws ec2 delete-snapshot --snapshot-id $snapshot_id
    done
done
