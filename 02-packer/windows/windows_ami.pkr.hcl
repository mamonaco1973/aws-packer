# ==============================================================================
# PACKER SETUP
# ==============================================================================
#
# This template builds a custom Windows Server 2022 AMI on AWS using the
# amazon-ebs builder. The build process provisions updates, security settings,
# browsers, desktop configuration, and prepares the image for reuse.
# ==============================================================================

packer {
  # --------------------------------------------------------------------------
  # Required plugins
  # --------------------------------------------------------------------------
  # Declare all external plugins required by this Packer template.
  required_plugins {
    amazon = {
      # Amazon builder plugin for creating AMIs with amazon-ebs.
      source  = "github.com/hashicorp/amazon"

      # Allow any compatible release within major version 1.
      version = "~> 1"
    }

    windows-update = {
      # Plugin used to manage Windows Updates during the image build.
      source  = "github.com/rgl/windows-update"

      # Explicit version pinning for deterministic and repeatable builds.
      version = "0.15.0"
    }
  }
}

# ==============================================================================
# DATA SOURCE: WINDOWS SERVER 2022 BASE AMI
# ==============================================================================
#
# Resolve the most recent Windows Server 2022 English base AMI published by AWS.
# This avoids hardcoding AMI IDs and ensures the build stays current.
# ==============================================================================

data "amazon-ami" "windows-base-os-image" {
  # --------------------------------------------------------------------------
  # AMI filters
  # --------------------------------------------------------------------------
  # Restrict results to official Windows Server 2022 EBS-backed HVM images.
  filters = {
    name                = "Windows_Server-2022-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }

  # Always select the most recent AMI matching the filters.
  most_recent = true

  # Official Windows AMIs are owned by the AWS account "amazon".
  owners = ["amazon"]
}

# ==============================================================================
# VARIABLES: REGION, INSTANCE, NETWORKING, AUTHENTICATION
# ==============================================================================

variable "region" {
  # AWS region where the build instance runs and the AMI is created.
  default = "us-east-2"
}

variable "instance_type" {
  # EC2 instance type used for the temporary Windows build host.
  # Windows builds require sufficient memory for updates and provisioning.
  default = "m5.large"
}

variable "vpc_id" {
  # VPC in which the temporary build instance will be launched.
  description = "The ID of the VPC to use"
  default     = ""
}

variable "subnet_id" {
  # Subnet in which the temporary build instance will be launched.
  # Must allow outbound internet access for Windows Updates.
  description = "The ID of the subnet to use"
  default     = ""
}

variable "password" {
  # Password used for the local Administrator account during provisioning.
  # Always supply this securely via CLI variables or environment secrets.
  description = "The password for the packer account"
  default     = ""
}

# ==============================================================================
# AMAZON-EBS SOURCE: WINDOWS SERVER AMI BUILD
# ==============================================================================
#
# The amazon-ebs builder launches a temporary EC2 instance, provisions it,
# creates a reusable AMI, and then terminates the instance.
# ==============================================================================

source "amazon-ebs" "windows_ami" {
  # --------------------------------------------------------------------------
  # Core build configuration
  # --------------------------------------------------------------------------
  region        = var.region
  instance_type = var.instance_type

  # Use the latest Windows Server 2022 AMI resolved by the data source.
  source_ami = data.amazon-ami.windows-base-os-image.id

  # Generate a unique AMI name using a sanitized timestamp.
  ami_name = "desktop_ami_${replace(timestamp(), ":", "-")}"

  # Launch the build instance in the specified VPC and subnet.
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # --------------------------------------------------------------------------
  # WinRM communicator configuration
  # --------------------------------------------------------------------------
  # WinRM is required for provisioning Windows EC2 instances.
  winrm_insecure = true
  winrm_use_ntlm = true
  winrm_use_ssl  = true

  # Default local administrator account.
  winrm_username = "Administrator"
  winrm_password = var.password

  communicator = "winrm"

  # --------------------------------------------------------------------------
  # Bootstrap configuration
  # --------------------------------------------------------------------------
  # Early initialization script injected via user_data.
  user_data = templatefile("./bootstrap_win.ps1", {
    password = var.password
  })

  # --------------------------------------------------------------------------
  # Root EBS volume configuration
  # --------------------------------------------------------------------------
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "64"
    volume_type           = "gp3"
    delete_on_termination = "true"
  }

  # Apply identifying tags to the resulting AMI.
  tags = {
    Name = "desktop_ami_${replace(timestamp(), ":", "-")}"
  }
}

# ==============================================================================
# BUILD: PROVISIONING AND IMAGE PREPARATION
# ==============================================================================
#
# Provisioners run sequentially to update the OS, install software, configure
# security, and prepare the image for reuse.
# ==============================================================================

build {
  # Reference the amazon-ebs source defined above.
  sources = ["source.amazon-ebs.windows_ami"]

  # --------------------------------------------------------------------------
  # Step 1: Install critical Windows Updates
  # --------------------------------------------------------------------------
  provisioner "windows-update" {}

  # --------------------------------------------------------------------------
  # Step 2: Restart the instance if required after updates
  # --------------------------------------------------------------------------
  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  # --------------------------------------------------------------------------
  # Step 3: Apply security configuration and user setup
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    script = "./security.ps1"
    environment_vars = [
      "PACKER_PASSWORD=${var.password}"
    ]
  }

  # --------------------------------------------------------------------------
  # Step 4: Create a working directory for post-build artifacts
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    inline = [
      "mkdir C:\\mcloud"
    ]
  }

  # --------------------------------------------------------------------------
  # Step 5: Upload boot-time configuration script
  # --------------------------------------------------------------------------
  provisioner "file" {
    source      = "./boot.ps1"
    destination = "C:\\mcloud\\"
  }

  # --------------------------------------------------------------------------
  # Step 6: Install and configure Google Chrome
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    script = "./chrome.ps1"
  }

  # --------------------------------------------------------------------------
  # Step 7: Install and configure Mozilla Firefox
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    script = "./firefox.ps1"
  }

  # --------------------------------------------------------------------------
  # Step 8: Configure desktop icons and shortcuts
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    script = "./desktop.ps1"
  }

  # --------------------------------------------------------------------------
  # Step 9: Final EC2Launch preparation (reset and sysprep)
  # --------------------------------------------------------------------------
  provisioner "powershell" {
    inline = [
      "Set-Location $env:ProgramFiles\\Amazon\\EC2Launch",
      "./ec2launch.exe reset -c",
      "./ec2launch.exe sysprep -c"
    ]
  }
}
