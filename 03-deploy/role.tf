# ==============================================================================
# IAM ROLE FOR EC2 SYSTEMS MANAGER (SSM) ACCESS
# ==============================================================================
#
# This module defines the IAM components required to allow EC2 instances
# to integrate with AWS Systems Manager (SSM).
#
# The configuration includes:
# - An IAM role that EC2 instances can assume
# - An AWS-managed policy attachment for SSM permissions
# - An instance profile to bind the role to EC2 instances
#
# This enables agent-based management via Session Manager, Run Command,
# Patch Manager, Inventory, and related SSM features.
# ==============================================================================

# ==============================================================================
# IAM ROLE: EC2 ASSUMABLE ROLE
# ==============================================================================

resource "aws_iam_role" "ssm_role" {
  # Name of the IAM role assumed by EC2 instances.
  name = "ssm-role"

  # Trust policy defining which principals can assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      # Allow the EC2 service to assume this role.
      Principal = {
        Service = "ec2.amazonaws.com"
      }

      # Required action for role assumption.
      Action = "sts:AssumeRole"
    }]
  })
}

# ==============================================================================
# IAM POLICY ATTACHMENT: SSM CORE PERMISSIONS
# ==============================================================================

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  # Attach the policy to the EC2 IAM role.
  role = aws_iam_role.ssm_role.name

  # AWS-managed policy providing core SSM permissions.
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ==============================================================================
# IAM INSTANCE PROFILE: BIND ROLE TO EC2
# ==============================================================================

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  # Instance profile name referenced by EC2 resources.
  name = "ssm-instance-profile"

  # Bind the IAM role to the instance profile.
  role = aws_iam_role.ssm_role.name
}
