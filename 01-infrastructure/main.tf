# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
#
# This provider block configures Terraform to interact with AWS services.
# Terraform uses the AWS provider to authenticate, plan, and apply resource
# changes defined in the configuration.
#
# The region setting determines where AWS resources will be created.
# Choosing the correct region is important for latency, availability,
# compliance, and cost considerations.
#
# Notes:
# - Ensure AWS credentials are configured securely before running Terraform.
# - Supported methods include environment variables, AWS CLI profiles,
#   instance roles, or Terraform-native authentication mechanisms.
# - Update the region value if deploying resources outside US East (Ohio).
# ==============================================================================

provider "aws" {
  # AWS region where all Terraform-managed resources will be created.
  region = "us-east-2"
}
