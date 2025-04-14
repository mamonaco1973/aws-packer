# Fetch AMIs with names starting with "flask_server_ami"
$region = "us-east-2"
$amis = aws ec2 describe-images `
    --owners self `
    --region $region `
    --filters "Name=name,Values=flask_server_ami*" `
    --query "Images[].ImageId" `
    --output text

# Split the output into an array of AMI IDs
$amiList = $amis -split "\s+"

foreach ($amiId in $amiList) {
    if ($amiId -ne "") {
        try {
            # Fetch and delete associated snapshots
            $snapshots = aws ec2 describe-images `
                --image-ids $amiId `
                --region $region `
                --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" `
                --output text
            
            $snapshotList = $snapshots -split "\s+"

            Write-Host "NOTE: Deregistering AMI: $amiId"
            aws ec2 deregister-image --image-id $amiId

            foreach ($snapshotId in $snapshotList) {
                if ($snapshotId -ne "") {
                    Write-Host "NOTE: Deleting snapshot: $snapshotId"
                    aws ec2 delete-snapshot --snapshot-id $snapshotId
                }
            }
        } catch {
            Write-Host "Error processing AMI: $amiId"
            Write-Host $_.Exception.Message
        }
    }
}
