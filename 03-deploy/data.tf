############################################
# DATA SOURCE: FETCH EXISTING VPC BY NAME TAG
############################################

data "aws_vpc" "packer_vpc" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-vpc"]             # Match the VPC named "packer-vpc"
  }
}

############################################
# DATA SOURCES: FETCH PUBLIC SUBNETS BY NAME TAG
############################################

# Fetch first public subnet by tag
data "aws_subnet" "packer_subnet_1" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-subnet-1"]        # Match the subnet named "packer-subnet-1"
  }
}

# Fetch second public subnet by tag
data "aws_subnet" "packer_subnet_2" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-subnet-2"]        # Match the subnet named "packer-subnet-2"
  }
}

############################################
# DATA SOURCES: FETCH SECURITY GROUPS BY TAG AND VPC ID
############################################

# Fetch security group for HTTP (port 80)
data "aws_security_group" "packer_sg_http" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-sg-http"]         # Match SG named "packer-sg-http"
  }
  vpc_id = data.aws_vpc.packer_vpc.id   # Ensure the SG is in the correct VPC
}

# Fetch security group for HTTPS (port 443)
data "aws_security_group" "packer_sg_https" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-sg-https"]        # Match SG named "packer-sg-https"
  }
  vpc_id = data.aws_vpc.packer_vpc.id   # Ensure the SG is in the correct VPC
}

# Fetch security group for SSH (port 22)
data "aws_security_group" "packer_sg_ssh" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-sg-ssh"]          # Match SG named "packer-sg-ssh"
  }
  vpc_id = data.aws_vpc.packer_vpc.id   # Ensure the SG is in the correct VPC
}

# Fetch security group for RDP (port 3389)
data "aws_security_group" "packer_sg_rdp" {
  filter {
    name   = "tag:Name"                 # Filter based on the "Name" tag
    values = ["packer-sg-rdp"]          # Match SG named "packer-sg-rdp"
  }
  vpc_id = data.aws_vpc.packer_vpc.id   # Ensure the SG is in the correct VPC
}

############################################
# DATA SOURCE: FETCH MOST RECENT AMI FOR GAME INSTANCES
############################################

data "aws_ami" "latest_games_ami" {
  most_recent = true                    # Return the most recently created AMI matching filters

  filter {
    name   = "name"                     # Filter AMIs by name pattern
    values = ["games_ami*"]             # Match AMI names starting with "games_ami"
  }

  filter {
    name   = "state"                    # Filter AMIs by state
    values = ["available"]              # Ensure AMI is in 'available' state
  }

  owners = ["self"]                     # Limit to AMIs owned by current AWS account
  # Use your AWS Account ID instead of "self" if pulling from a shared account
}

############################################
# DATA SOURCE: FETCH MOST RECENT AMI FOR DESKTOP
############################################

data "aws_ami" "latest_desktop_ami" {
  most_recent = true                    # Return the most recently created AMI matching filters

  filter {
    name   = "name"                     # Filter AMIs by name pattern
    values = ["desktop_ami*"]             # Match AMI names starting with "games_ami"
  }

  filter {
    name   = "state"                    # Filter AMIs by state
    values = ["available"]              # Ensure AMI is in 'available' state
  }

  owners = ["self"]                     # Limit to AMIs owned by current AWS account
  # Use your AWS Account ID instead of "self" if pulling from a shared account
}

