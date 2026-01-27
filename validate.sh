#!/bin/bash

# ==============================================================================
# VALIDATION SCRIPT: DEPLOYED INSTANCE VERIFICATION
# ==============================================================================
#
# This script validates that EC2 instances deployed by the apply pipeline
# are running and reachable by querying AWS for their public DNS names.
#
# It performs read-only operations and does not modify infrastructure.
# The output can be used to confirm successful deployment or for quick access.
# ==============================================================================

export AWS_DEFAULT_REGION="us-east-2"

# ------------------------------------------------------------------------------
# Strict shell behavior
# ------------------------------------------------------------------------------
# -e            Exit immediately if any command fails
# -u            Treat unset variables as errors
# -o pipefail   Fail if any command in a pipeline fails
# ------------------------------------------------------------------------------
set -euo pipefail

# ==============================================================================
# VALIDATE LINUX GAMES SERVER
# ==============================================================================
#
# Query AWS for the public DNS name of the running Linux EC2 instance that
# hosts the games server.
# ==============================================================================

linux_server=$(aws ec2 describe-instances \
  --filters \
    "Name=tag:Name,Values=games-ec2-instance" \
    "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicDnsName" \
  --output text)

# Print access information for the games server.
echo "NOTE: Games URL is http://$linux_server"
echo "NOTE: Games server FQDN is $linux_server"

# ==============================================================================
# VALIDATE WINDOWS DESKTOP SERVER
# ==============================================================================
#
# Query AWS for the public DNS name of the running Windows EC2 instance.
# ==============================================================================

windows_server=$(aws ec2 describe-instances \
  --filters \
    "Name=tag:Name,Values=desktop-ec2-instance" \
    "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicDnsName" \
  --output text)

# Print access information for the Windows desktop server.
echo "NOTE: Windows server FQDN is $windows_server"
