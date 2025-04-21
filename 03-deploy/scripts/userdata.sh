#!/bin/bash
# Script runs on first boot — modify SSH server configuration to allow password-based login

sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
# Replace 'no' with 'yes' to enable password login for SSH

systemctl restart sshd
# Restart SSH daemon to apply the new authentication setting

echo "The AMI name is ${ami_name}."

