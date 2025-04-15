#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Adding sleep to give mirrors time to sync..."
sleep 60

echo "Updating apt cache manually..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y

# Correct usage of environment var with sudo
sudo DEBIAN_FRONTEND=noninteractive apt-get install apache2 -y
sudo systemctl enable apache2 >/dev/null 2>&1
sudo systemctl start apache2 >/dev/null 2>&1

sudo cp /tmp/html/* /var/www/html/

# Ensure snap is ready
sudo systemctl start snapd
sudo systemctl enable snapd

# Start the snap-managed SSM agent
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
