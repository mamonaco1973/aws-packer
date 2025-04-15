#!/bin/bash

# Create the 'packer' user without a home directory
sudo useradd -m -s /bin/bash packer

# Set the user's password using chpasswd
echo "packer:$PACKER_PASSWORD" | sudo chpasswd

# Grant passwordless sudo access
echo "packer ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/packer
sudo chmod 440 /etc/sudoers.d/packer
