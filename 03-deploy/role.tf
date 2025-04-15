############################################
# IAM ROLE: EC2 INSTANCE ROLE FOR SSM ACCESS
############################################

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"                                     # Name of the IAM role to attach to EC2 instances

  # Trust policy — defines who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",                             # IAM policy language version
    Statement = [{
      Effect    = "Allow",                              # Allow assumption of this role
      Principal = {
        Service = "ec2.amazonaws.com"                   # Grant EC2 service permission to assume this role
      },
      Action = "sts:AssumeRole"                         # Required for EC2 to assume the IAM role
    }]
  })
}

############################################
# ATTACH AWS-MANAGED POLICY: AmazonSSMManagedInstanceCore
############################################

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name              # Attach policy to the previously defined role
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # Grants EC2 instances permission to use AWS Systems Manager (SSM):
  # - Enables Session Manager, Run Command, Inventory, Patch Manager, etc.
}

############################################
# IAM INSTANCE PROFILE: BIND ROLE TO EC2
############################################

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"                         # Name of the EC2 instance profile
  role = aws_iam_role.ssm_role.name                     # Bind the IAM role to the profile
  # Instance profiles are required for EC2 to use IAM roles — they act as a container for the role
}
