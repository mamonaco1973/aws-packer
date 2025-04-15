############################################
# PACKER CONFIGURATION AND PLUGIN SETUP
############################################

# Define global Packer settings and plugin dependencies
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"     # Official Amazon plugin source from HashiCorp
      version = "~> 1"                             # Allow any compatible version within major version 1
    }
  }
}

############################################
# DATA SOURCE: BASE UBUNTU AMI FROM CANONICAL
############################################

data "amazon-ami" "linux-base-os-image" {
  filters = {
    name                = "*ubuntu-noble-24.04-amd64-*"  # Match only Ubuntu 24.04 (Noble) 64-bit AMIs
    root-device-type    = "ebs"                          # Must be EBS-backed
    virtualization-type = "hvm"                          # Use hardware-assisted virtualization
  }

  most_recent = true                                     # Always select the latest AMI version available
  owners      = ["099720109477"]                         # Canonical’s official AWS account ID
}

############################################
# VARIABLES: REGION, INSTANCE SETTINGS, NETWORKING, AUTH
############################################

variable "region" {
  default = "us-east-2"                                  # AWS region: US East (Ohio)
}

variable "instance_type" {
  default = "t2.micro"                                   # Default instance type: t2.micro (free-tier eligible)
}

variable "vpc_id" {
  description = "The ID of the VPC to use"               # User-supplied VPC ID
  default     = ""                                       # Replace this at runtime or via command-line vars
}

variable "subnet_id" {
  description = "The ID of the subnet to use"            # User-supplied Subnet ID
  default     = ""                                       # Replace this at runtime or via command-line vars
}

variable "password" {
  description = "The password for the packer account"    # Will be passed into SSH provisioning script
  default     = ""                                       # Must be overridden securely via env or CLI
}

############################################
# AMAZON-EBS SOURCE BLOCK: BUILD CUSTOM UBUNTU IMAGE
############################################

source "amazon-ebs" "ubuntu_ami" {
  region                = var.region                     # Use configured AWS region
  instance_type         = var.instance_type              # Use configured EC2 instance type
  source_ami            = data.amazon-ami.linux-base-os-image.id  # Use latest Ubuntu 24.04 AMI
  ssh_username          = "ubuntu"                       # Default Ubuntu AMI login user
  ami_name              = "games_ami_${replace(timestamp(), ":", "-")}" # Unique AMI name using timestamp
  ssh_interface         = "public_ip"                    # Use public IP for provisioning connection
  vpc_id                = var.vpc_id                     # Use specific VPC (required for custom networking)
  subnet_id             = var.subnet_id                  # Use specific subnet (must allow outbound internet)

  # Define EBS volume settings
  launch_block_device_mappings {
    device_name           = "/dev/sda1"                  # Root device name
    volume_size           = "16"                         # Size in GiB for root volume
    volume_type           = "gp3"                        # Use gp3 volume for better performance
    delete_on_termination = "true"                       # Ensure volume is deleted with instance
  }

  tags = {
    Name = "games_ami_${replace(timestamp(), ":", "-")}" # Tag the AMI with a recognizable name
  }
}

############################################
# BUILD BLOCK: PROVISION FILES AND RUN SETUP SCRIPTS
############################################

build {
  sources = ["source.amazon-ebs.ubuntu_ami"]             # Use the previously defined EBS source

  # Create a temp directory for HTML files
  provisioner "shell" {
    inline = ["mkdir -p /tmp/html"]                      # Ensure target directory exists on VM
  }

  # Copy local HTML files to the instance
  provisioner "file" {
    source      = "./html/"                              # Source directory from local machine
    destination = "/tmp/html/"                           # Target directory inside VM
  }

  # Run install script inside the instance
  provisioner "shell" {
    script = "./install.sh"                              # Installs and configures required packages
  }

  # Run SSH configuration script, passing in a password variable
  provisioner "shell" {
    script = "./config_ssh.sh"                           # Custom script to enable SSH password login
    environment_vars = [
      "PACKER_PASSWORD=${var.password}"                  # Export password to the script environment
    ]
  }
}
