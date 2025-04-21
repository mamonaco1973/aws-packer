############################################
# DATA SOURCE: FETCH EXISTING VPC BY NAME TAG
############################################

data "aws_vpc" "packer_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name_tag]
  }
}

############################################
# DATA SOURCES: FETCH PUBLIC SUBNETS BY NAME TAG
############################################

data "aws_subnet" "packer_subnet_1" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_tag_1]
  }
}

data "aws_subnet" "packer_subnet_2" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_tag_2]
  }
}

############################################
# DATA SOURCES: FETCH SECURITY GROUPS BY TAG AND VPC ID
############################################

data "aws_security_group" "packer_sg_http" {
  filter {
    name   = "tag:Name"
    values = [var.sg_name_http]
  }
  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_https" {
  filter {
    name   = "tag:Name"
    values = [var.sg_name_https]
  }
  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_ssh" {
  filter {
    name   = "tag:Name"
    values = [var.sg_name_ssh]
  }
  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_security_group" "packer_sg_rdp" {
  filter {
    name   = "tag:Name"
    values = [var.sg_name_rdp]
  }
  vpc_id = data.aws_vpc.packer_vpc.id
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

