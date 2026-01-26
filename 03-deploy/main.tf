# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
#
# This provider block configures Terraform to communicate with AWS services.
# The AWS provider is required to authenticate, plan, and manage all AWS
# resources defined in this configuration.
#
# The region setting determines where resources will be created and managed.
# Selecting the correct region is important for latency, cost, availability,
# and regulatory or compliance requirements.
#
# Notes:
# - Ensure AWS credentials are configured securely before running Terraform.
# - Supported methods include AWS CLI profiles, environment variables,
#   instance or task roles, and Terraform-native authentication.
# - Update the region value if deploying resources outside US East (Ohio).
# ==============================================================================

provider "aws" {
  # AWS region where Terraform-managed resources will be created.
  region = "us-east-2"
}
