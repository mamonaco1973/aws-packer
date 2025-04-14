# Configure the AWS provider block
# This section establishes the configuration for the AWS provider, which is essential for Terraform to communicate with AWS services.
# The provider is responsible for managing and provisioning AWS resources defined in your Terraform code.
# 
# 'region' specifies the AWS region where Terraform will create and manage resources.
# It is critical to set this value correctly, as deploying resources in an incorrect region can lead to higher latency, unexpected costs, or compliance issues.
# 
# Note:
# - Ensure the AWS credentials (e.g., access keys) are properly configured in your environment.
# - Use the AWS CLI, environment variables, or Terraform's native authentication methods for secure credential management.
# - Replace "us-east-2" with the desired region code (e.g., "us-west-1") if deploying to a different AWS region.

provider "aws" {
  region = "us-east-2" # Default region set to US East (Ohio). Modify if your deployment requires another region.
}

# Key Pair for Secure EC2 Instance Access
resource "aws_key_pair" "flask-key" {
  key_name   = "flask-key"                   # Name of the key pair in AWS
  public_key = file("./keys/EC2_key_public")     # Path to the public key file for SSH access
}

# Number of instances to deploy in the autoscaling group
# This variable defines the number of EC2 instances to be deployed within the Auto Scaling Group.
# Adjust this value as necessary to meet the desired scalability and workload requirements.
variable "asg_instances" {
  default = 0 
}

# The AMI (Amazon Machine Image) to use in the launch template attached to the autoscaling group.

variable "default_ami" {
  default = "ami-0c80e2b6ccb9ad6d1" # Replace with your own AMI ID for customized deployments.
}

# Define a resource group based on "ResourceGroup=flask-asg-rg" tagging
# We will compare resource groups between the three cloud

resource "aws_resourcegroups_group" "flask_asg_rg" {
  name        = "flask-asg-rg"
  description = "Resource group for Flask ASG resources"

    resource_query {
    type  = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"] # Include all resource types
      TagFilters = [
        {
          Key    = "ResourceGroup"
          Values = ["flask-asg-rg"]
        }
      ]
    })
  }
}

