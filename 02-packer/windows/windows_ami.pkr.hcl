############################################
#              PACKER SETUP
############################################

# Declare global packer settings
packer {
  required_plugins {
    amazon = {
      # Required for building AMIs on AWS using amazon-ebs
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"  # Allow all versions within major version 1.x
    }
    windows-update = {
      # Plugin for handling Windows Update during build
      source  = "github.com/rgl/windows-update"
      version = "0.15.0"  # Explicit version pinning for reliability
    }
  }
}

############################################
#        FETCH WINDOWS 2022 BASE AMI
############################################

data "amazon-ami" "windows-base-os-image" {
  filters = {
    name                = "Windows_Server-2022-English-Full-Base-*"  # Match latest Windows Server 2022
    root-device-type    = "ebs"                                      # Ensure EBS-based AMIs
    virtualization-type = "hvm"                                      # Required for modern EC2 types
  }
  most_recent = true     # Always grab the most recent version
  owners      = ["amazon"]  # Official AMIs owned by AWS
}

############################################
#           PARAMETER VARIABLES
############################################

variable "region" {
  default = "us-east-2"  # Default to Ohio region; override via CLI if needed
}

variable "instance_type" {
  default = "t3.medium"  # Good baseline for Windows builds (>=2GB RAM needed)
}

variable "vpc_id" {
  description = "The ID of the VPC to use"  
  default     = ""  # Must be supplied at runtime unless using default VPC
}

variable "subnet_id" {
  description = "The ID of the subnet to use"
  default     = ""  # Must be public or have NAT for internet access (Windows updates)
}

variable "password" {
  description = "The password for the packer account"
  default     = ""  # MUST be securely passed in via env var or CLI — DO NOT hardcode!
}

############################################
#      MAIN SOURCE BLOCK - WINDOWS AMI
############################################

source "amazon-ebs" "windows_ami" {
  region         = var.region
  instance_type  = var.instance_type
  source_ami     = data.amazon-ami.windows-base-os-image.id
  ami_name       = "desktop_ami_${replace(timestamp(), ":", "-")}"  # Time-stamped name for uniqueness
  vpc_id         = var.vpc_id
  subnet_id      = var.subnet_id

  # WinRM configuration (required to talk to Windows EC2)
  winrm_insecure = true             # Allow self-signed cert
  winrm_use_ntlm = true             # NTLM auth required in many builds
  winrm_use_ssl  = true             # Always use SSL for encryption
  winrm_username = "Administrator"  # Default admin user
  winrm_password = var.password     # Strong password required or connection fails
  communicator   = "winrm"

  # Bootstrap script injected as user_data for early config
  user_data = templatefile("./bootstrap_win.ps1", {
    password = var.password  # Inject password into template (handle with care)
  })

  # Define root volume settings
  launch_block_device_mappings {
    device_name           = "/dev/sda1"  # Root volume mount
    volume_size           = "64"         # 64 GiB default size
    volume_type           = "gp3"        # gp3 = better performance + cost than gp2
    delete_on_termination = "true"       # Auto-cleanup of root disk when instance deleted
  }

  tags = {
    Name = "desktop_ami_${replace(timestamp(), ":", "-")}"  # Helpful for visual filtering in AWS Console
  }
}

############################################
#             BUILD PROCESS
############################################

build {
  sources = ["source.amazon-ebs.windows_ami"]  # Reference the source block

  # Step 1: Install critical Windows Updates
  provisioner "windows-update" {}

  # Step 2: Restart if required post-updates (15 min timeout)
  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  # Step 3: Run your own script to configure users/security
  provisioner "powershell" {
    script = "./security.ps1"  # Creates local users, disables services, etc.
    environment_vars = [
      "PACKER_PASSWORD=${var.password}"  # Secure way to pass secret value
    ]
  }

  # Step 4: Create target directory for postbuild artifacts
  provisioner "powershell" {
    inline = [
      "mkdir c:\\mcloud"  # Used as drop location for additional files
    ]
  }

  # Step 5: Upload boot configuration script
  provisioner "file" {
    source      = "./boot.ps1"        # Local path
    destination = "C:\\mcloud\\"      # Remote Windows path
  }

  # Step 6: Run script to install/configure Chrome
  provisioner "powershell" {
    script = "./chrome.ps1"
  }

  # Step 7: Run script to install/configure Firefox
  provisioner "powershell" {
    script = "./firefox.ps1"
  }

  # Step 8: Configure desktop icons
  provisioner "powershell" {
    script = "./desktop.ps1"
  }

  # Step 9: Final prep using EC2Launch — handles sysprep, reset, etc.
  provisioner "powershell" {
    inline = [
      "Set-Location $env:programfiles/amazon/ec2launch",  # Go to EC2Launch folder
      "./ec2launch.exe reset -c ",                        # Reset machine to preconfigured state
      "./ec2launch.exe sysprep -c "                       # Run sysprep to make AMI reusable
    ]
  }
}
