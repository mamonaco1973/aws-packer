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
    windows-update = {
      source  = "github.com/rgl/windows-update"
      version = "0.15.0"
    }
  }
}

############################################
# DATA SOURCE: WINDOWS 2022 FROM AMAZON
############################################

data "amazon-ami" "windows-base-os-image" {
  filters = {
    name                = "Windows_Server-2022-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
}

############################################
# VARIABLES: REGION, INSTANCE SETTINGS, NETWORKING, AUTH
############################################

variable "region" {
  default = "us-east-2"                                  # AWS region: US East (Ohio)
}

variable "instance_type" {
  default = "t3.medium"                                   # Default instance type: t3.medium
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
  description = "The password for the packer account"    # Will be passed into provisioning script
  default     = ""                                       # Must be overridden securely via env or CLI
}

############################################
# AMAZON-EBS SOURCE BLOCK: BUILD CUSTOM UBUNTU IMAGE
############################################

source "amazon-ebs" "windows_ami" {
  region                = var.region                     # Use configured AWS region
  instance_type         = var.instance_type              # Use configured EC2 instance type
  source_ami            = data.amazon-ami.windows-base-os-image.id # Use latest Windows 2022 AMI
  ami_name              = "desktop_ami_${replace(timestamp(), ":", "-")}" # Unique AMI name using timestamp
  vpc_id                = var.vpc_id                     # Use specific VPC (required for custom networking)
  subnet_id             = var.subnet_id                  # Use specific subnet (must allow outbound internet)
  winrm_insecure   = true
  winrm_use_ntlm   = true
  winrm_use_ssl    = true
  winrm_username   = "Administrator"
  winrm_password   = var.password 
  communicator     = "winrm"
  user_data = templatefile("./bootstrap_win.ps1", {
                         password = var.password
                         })

 # Define EBS volume settings
  launch_block_device_mappings {
    device_name           = "/dev/sda1"                  # Root device name
    volume_size           = "64"                         # Size in GiB for root volume
    volume_type           = "gp3"                        # Use gp3 volume for better performance
    delete_on_termination = "true"                       # Ensure volume is deleted with instance
  }

  tags = {
    Name = "desktop_ami_${replace(timestamp(), ":", "-")}" # Tag the AMI with a recognizable name
  }
}

############################################
# BUILD BLOCK: PROVISION FILES AND RUN SETUP SCRIPTS
############################################

build {
  sources = ["source.amazon-ebs.windows_ami"]             # Use the previously defined EBS source
 
  # Add the windows-update provisioner here
  provisioner "windows-update" {}

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "powershell" {
    inline = [
      #Sysprep the instance with ECLaunch v2. Reset enables runonce scripts again.
      "Set-Location $env:programfiles/amazon/ec2launch",
      "./ec2launch.exe reset -c -b",
      "./ec2launch.exe sysprep -c -b"
    ]
  }

  # Run SSH configuration script, passing in a password variable
  #provisioner "shell" {
  # script = "./config_ssh.sh"                           # Custom script to enable SSH password login
  #  environment_vars = [
  #    "PACKER_PASSWORD=${var.password}"                  # Export password to the script environment
  #  ]
  #}
}
