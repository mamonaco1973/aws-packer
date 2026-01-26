# ==============================================================================
# PACKER CONFIGURATION AND PLUGIN SETUP
# ==============================================================================
#
# This template builds a custom Ubuntu 24.04 AMI in AWS using the amazon-ebs
# builder. The high-level workflow is:
#
#   1. Discover the latest Canonical Ubuntu 24.04 base AMI
#   2. Launch a temporary EC2 instance in the target VPC and subnet
#   3. Provision files and execute configuration scripts
#   4. Create a new AMI and terminate the build instance
#
# Network identifiers and sensitive values are supplied at runtime to avoid
# hardcoding environment-specific configuration or secrets.
# ==============================================================================

packer {
  # --------------------------------------------------------------------------
  # Required plugins
  # --------------------------------------------------------------------------
  # Declare external plugins required by this Packer template.
  required_plugins {
    amazon = {
      # Official Amazon builder plugin maintained by HashiCorp.
      source  = "github.com/hashicorp/amazon"

      # Allow any compatible release within major version 1.
      version = "~> 1"
    }
  }
}

# ==============================================================================
# DATA SOURCE: BASE UBUNTU AMI FROM CANONICAL
# ==============================================================================
#
# Resolve the most recent Canonical-provided Ubuntu 24.04 (Noble) AMI.
# This avoids hardcoding AMI IDs and ensures builds stay current.
# ==============================================================================

data "amazon-ami" "linux-base-os-image" {
  # --------------------------------------------------------------------------
  # AMI filters
  # --------------------------------------------------------------------------
  # Constrain the search to Ubuntu 24.04 AMD64 images with EBS-backed storage.
  filters = {
    name                = "*ubuntu-noble-24.04-amd64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }

  # Always select the newest AMI that matches the filters.
  most_recent = true

  # Canonical's official AWS account ID.
  owners = ["099720109477"]
}

# ==============================================================================
# VARIABLES: REGION, INSTANCE SETTINGS, NETWORKING, AUTHENTICATION
# ==============================================================================

variable "region" {
  # AWS region where the build instance runs and the AMI is created.
  default = "us-east-2"
}

variable "instance_type" {
  # EC2 instance type used for the temporary build host.
  default = "m5.large"
}

variable "vpc_id" {
  # VPC in which the temporary build instance will be launched.
  description = "The ID of the VPC to use"
  default     = ""
}

variable "subnet_id" {
  # Subnet in which the temporary build instance will be launched.
  # The subnet must allow outbound access for package installation.
  description = "The ID of the subnet to use"
  default     = ""
}

variable "password" {
  # Password injected into provisioning scripts for SSH configuration.
  # Override securely via CLI variables or environment-based secrets.
  description = "The password for the packer account"
  default     = ""
}

# ==============================================================================
# AMAZON-EBS SOURCE: CUSTOM UBUNTU AMI BUILD
# ==============================================================================
#
# The amazon-ebs builder launches a temporary EC2 instance from the source AMI,
# applies provisioning steps, creates a new AMI, and then terminates the instance.
# ==============================================================================

source "amazon-ebs" "ubuntu_ami" {
  # --------------------------------------------------------------------------
  # Core build configuration
  # --------------------------------------------------------------------------
  region        = var.region
  instance_type = var.instance_type

  # Use the latest Ubuntu 24.04 AMI resolved via the data source.
  source_ami = data.amazon-ami.linux-base-os-image.id

  # Default SSH username for Canonical Ubuntu images.
  ssh_username = "ubuntu"

  # Generate a unique AMI name using a sanitized timestamp.
  ami_name = "games_ami_${replace(timestamp(), ":", "-")}"

  # Use the instance public IP for the SSH provisioning connection.
  ssh_interface = "public_ip"

  # Launch the build instance in the specified VPC and subnet.
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # --------------------------------------------------------------------------
  # Root EBS volume configuration
  # --------------------------------------------------------------------------
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "16"
    volume_type           = "gp3"
    delete_on_termination = "true"
  }

  # Apply identifying tags to the resulting AMI.
  tags = {
    Name = "games_ami_${replace(timestamp(), ":", "-")}"
  }
}

# ==============================================================================
# BUILD: FILE PROVISIONING AND CONFIGURATION SCRIPTS
# ==============================================================================
#
# Provisioners run sequentially against the temporary build instance to install
# software, copy assets, and apply system configuration.
# ==============================================================================

build {
  # Reference the amazon-ebs source defined above.
  sources = ["source.amazon-ebs.ubuntu_ami"]

  # --------------------------------------------------------------------------
  # Prepare temporary directories on the instance
  # --------------------------------------------------------------------------
  provisioner "shell" {
    inline = ["mkdir -p /tmp/html"]
  }

  # --------------------------------------------------------------------------
  # Copy static HTML assets to the instance
  # --------------------------------------------------------------------------
  provisioner "file" {
    source      = "./html/"
    destination = "/tmp/html/"
  }

  # --------------------------------------------------------------------------
  # Run the primary installation and configuration script
  # --------------------------------------------------------------------------
  provisioner "shell" {
    script = "./install.sh"
  }

  # --------------------------------------------------------------------------
  # Configure SSH settings using a password passed via environment variables
  # --------------------------------------------------------------------------
  provisioner "shell" {
    script = "./config_ssh.sh"
    environment_vars = [
      "PACKER_PASSWORD=${var.password}"
    ]
  }
}
