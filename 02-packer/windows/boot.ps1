try {
    echo "NOTE: AMI provisioned boot script ran" > c:\mcloud\boot.log
}
catch {
    Write-Error "An error occurred in the boot script."
    exit 1
}
