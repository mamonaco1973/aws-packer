
#!/bin/bash

export AWS_DEFAULT_REGION="us-east-2"

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

cd 03-deploy

terraform init
terraform destroy -auto-approve

cd ..

cd 01-infrastructure

terraform init
terraform destroy -auto-approve

cd ..

