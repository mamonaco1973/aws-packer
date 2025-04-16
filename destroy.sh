
#!/bin/bash

export AWS_DEFAULT_REGION="us-east-2"

cd 03-deploy

terraform init
terraform destroy -auto-approve

cd ..

# Delete all versions of the games_ami
for ami_id in $(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=games_ami*" \
    --query "Images[].ImageId" \
    --output text); do

    # Fetch and delete associated snapshots
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


# Delete all versions of the desktop_ami
for ami_id in $(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=desktop_ami*" \
    --query "Images[].ImageId" \
    --output text); do

    # Fetch and delete associated snapshots
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

aws secretsmanager delete-secret --secret-id "packer-credentials" --force-delete-without-recovery

cd 01-infrastructure

terraform init
terraform destroy -auto-approve

cd ..

