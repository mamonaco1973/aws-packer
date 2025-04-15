#!/bin/bash

# Set non-interactive mode for APT operations to avoid prompts during automation
export DEBIAN_FRONTEND=noninteractive

# Wait for 60 seconds to allow APT mirrors and background services to settle
# This is often necessary in freshly booted cloud VMs where apt-daily may still be locking the package manager
echo "Adding sleep to give mirrors time to sync..."
sleep 60

# Manually update the local APT package cache
# Ensures we have the latest package info before installing anything
echo "Updating apt cache manually..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y

# Install Apache2 web server using APT
# -y flag ensures automatic yes to prompts; env var ensures no interactive dialogs
# Re-declaring DEBIAN_FRONTEND with sudo to ensure it propagates inside the command
sudo DEBIAN_FRONTEND=noninteractive apt-get install apache2 -y

# Enable Apache2 to start automatically on boot
# Suppress all stdout/stderr output for cleanliness/log minimization
sudo systemctl enable apache2 >/dev/null 2>&1

# Start Apache2 service immediately
# Again, suppress output to avoid noisy logs or unnecessary error display
sudo systemctl start apache2 >/dev/null 2>&1

# Copy prebuilt website content from /tmp/html to Apache's default document root
# Assumes files are staged ahead of time (e.g., by Packer or cloud-init)
sudo cp /tmp/html/* /var/www/html/

# Ensure snapd (Snap package manager daemon) is started
# Required for launching snap-managed services like amazon-ssm-agent
sudo systemctl start snapd

# Enable snapd to start on boot to persist snap capabilities after reboot
sudo systemctl enable snapd

# Enable the snap-installed AWS Systems Manager (SSM) agent at boot
# Full service name required due to nested naming used by Snap packages
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service

# Start the AWS SSM agent immediately so the instance can register with AWS Systems Manager
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
