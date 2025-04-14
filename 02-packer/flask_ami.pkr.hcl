# Specify the Packer configuration
packer {
  # Define the required plugins for Packer
  required_plugins {
    amazon = {
      # Amazon plugin source and version
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

# Data source to retrieve information about the Amazon Linux 2023 AMI
data "amazon-ami" "linux-base-os-image" {
  # Filters to find the specific AMI
  filters = {
    name                = "al2023-ami-2023*x86_64"  # Match AMI name pattern
    root-device-type    = "ebs"                     # Ensure it's EBS-backed
    virtualization-type = "hvm"                     # HVM virtualization
  }
  most_recent = true         # Use the most recent AMI matching the criteria
  owners      = ["amazon"]   # Only fetch AMIs owned by Amazon
}

# Define a variable for the AWS region
variable "region" {
  default = "us-east-2"  # Default region set to US East (Ohio)
}

# Define a variable for the instance type
variable "instance_type" {
  default = "t2.micro"  # Default instance type set to t2.micro
}

# Define a variable for the VPC ID
variable "vpc_id" {
  description = "The ID of the VPC to use"
  default     = ""  # Replace with your actual VPC ID if needed
}

# Define a variable for the subnet ID
variable "subnet_id" {
  description = "The ID of the subnet to use"
  default     = ""  # Replace with your actual subnet ID if needed
}

# Define the Amazon EBS source for building the AMI
source "amazon-ebs" "flask_ami" {
  region            = var.region                 # Use the region variable
  instance_type     = var.instance_type          # Use the instance type variable
  source_ami        = data.amazon-ami.linux-base-os-image.id  # Base AMI ID
  ssh_username      = "ec2-user"                 # Default user for Amazon Linux
  ami_name          = "flask_server_ami_${replace(timestamp(), ":", "-")}"  # Unique AMI name with timestamp
  ssh_interface     = "public_ip"                # Use public IP for SSH
  vpc_id            = var.vpc_id                 # VPC ID for the instance
  subnet_id         = var.subnet_id              # Subnet ID for the instance

  tags = {
    ResourceGroup = "flask-asg-rg"               # Tag for resource manager
    Name          = "flask_server_ami_${replace(timestamp(), ":", "-")}"  
  }
}

# Define the build configuration
build {
  # Use the Amazon EBS source defined above
  sources = ["source.amazon-ebs.flask_ami"]

  # Provisioner to run shell commands during the build
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /flask",      # Create the /flask directory
      "sudo chmod 777 /flask"      # Set permissions to allow access
    ]
  }

  # Provisioner to copy local scripts to the instance
  provisioner "file" {
    source      = "./scripts/"    # Path to the local scripts directory
    destination = "/flask/"       # Destination directory on the instance
  }

  # Provisioner to run a shell script during the build
  provisioner "shell" {
    script = "./install.sh"       # Path to the install script
  }
}
