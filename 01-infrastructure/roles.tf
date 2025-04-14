# IAM Role for EC2 instances to assume, granting specific permissions
resource "aws_iam_role" "flask_ec2_role" {
  name = "flask-ec2-role"                      # IAM Role name

  # Trust relationship policy allowing EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",                     # Policy language version
    Statement = [
      {
        Effect = "Allow",                       # Grant permission to assume the role
        Principal = {
          Service = "ec2.amazonaws.com"         # Allow EC2 service to assume this role
        },
        Action = "sts:AssumeRole"               # Required action to assume roles
      }
    ]
  })
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "flask_access_policy" {
  name        = "flask-access-policy"           # IAM Policy name
  description = "Policy that allows specific access to the DynamoDB Candidates table"

  # JSON policy document defining permissions
  policy = jsonencode({
    Version = "2012-10-17",                     # Policy version
    Statement = [
      {
        Effect = "Allow",                       # Grant the defined actions
        Action = [                              # Actions allowed on the DynamoDB table
          "dynamodb:Query",
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        Resource = "${aws_dynamodb_table.candidate-table.arn}"  # Target DynamoDB table ARN
      }
    ]
  })
}

# Attach the DynamoDB access policy to the EC2 IAM Role
resource "aws_iam_role_policy_attachment" "attach_access_policy" {
  role       = aws_iam_role.flask_ec2_role.name        # IAM Role to attach the policy
  policy_arn = aws_iam_policy.flask_access_policy.arn  # Policy ARN to attach
}

# Attach the AmazonSSMManagedInstanceCore policy for SSM access
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.flask_ec2_role.name  # IAM Role to attach the policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # SSM Managed Policy ARN
}
