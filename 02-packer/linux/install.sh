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
