# ==============================================================================
# DATA SOURCES: LOOK UP EXISTING NETWORKING BY TAG
# ==============================================================================
#
# These data sources discover pre-existing AWS resources by tag instead of
# creating new infrastructure. This allows Packer and Terraform to integrate
# cleanly with shared or centrally managed environments.
# ==============================================================================

# ==============================================================================
# VPC: LOOKUP BY NAME TAG
# ==============================================================================

data "aws_vpc" "packer_vpc" {
  # Resolve the target VPC using its Name tag value.
  filter {
    name   = "tag:Name"
    values = [var.vpc_name_tag]
  }
}

# ==============================================================================
# SUBNETS: LOOKUP PUBLIC SUBNETS BY NAME TAG
# ==============================================================================

data "aws_subnet" "packer_subnet_1" {
  # Resolve the first public subnet using its Name tag.
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_tag_1]
  }
}

data "aws_subnet" "packer_subnet_2" {
  # Resolve the second public subnet using its Name tag.
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_tag_2]
  }
}

# ==============================================================================
# SECURITY GROUPS: LOOKUP BY NAME TAG AND VPC
# ==============================================================================
#
# Security groups are resolved by Name tag and constrained to the selected VPC
# to avoid accidental matches across environments.
# ==============================================================================

data "aws_security_group" "packer_sg_http" {
  # Lookup the HTTP security group within the target VPC.
  filter {
    name   = "tag:Name"
    values = [var.sg_name_http]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_https" {
  # Lookup the HTTPS security group within the target VPC.
  filter {
    name   = "tag:Name"
    values = [var.sg_name_https]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_ssh" {
  # Lookup the SSH security group within the target VPC.
  filter {
    name   = "tag:Name"
    values = [var.sg_name_ssh]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_rdp" {
  # Lookup the RDP security group within the target VPC.
  filter {
    name   = "tag:Name"
    values = [var.sg_name_rdp]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

# ==============================================================================
# AMI LOOKUP: MOST RECENT GAMES IMAGE
# ==============================================================================
#
# Select the most recently created AMI matching the expected naming convention.
# This is typically an image produced by a prior Packer build.
# ==============================================================================

data "aws_ami" "latest_games_ami" {
  # Always return the most recent AMI matching the filters.
  most_recent = true

  # Match AMIs created with the "games_ami" naming prefix.
  filter {
    name   = "name"
    values = ["games_ami*"]
  }

  # Ensure the AMI is available for use.
  filter {
    name   = "state"
    values = ["available"]
  }

  # Limit results to AMIs owned by the current AWS account.
  owners = ["self"]
}

# ==============================================================================
# AMI LOOKUP: MOST RECENT DESKTOP IMAGE
# ==============================================================================
#
# Select the most recent desktop AMI produced by the Windows Packer pipeline.
# ==============================================================================

data "aws_ami" "latest_desktop_ami" {
  # Always return the most recent AMI matching the filters.
  most_recent = true

  # Match AMIs created with the "desktop_ami" naming prefix.
  filter {
    name   = "name"
    values = ["desktop_ami*"]
  }

  # Ensure the AMI is available for use.
  filter {
    name   = "state"
    values = ["available"]
  }

  # Limit results to AMIs owned by the current AWS account.
  owners = ["self"]
}
