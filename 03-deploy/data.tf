# Data source to fetch the VPC by tag
data "aws_vpc" "packer_vpc" {
  filter {
    name   = "tag:Name"
    values = ["packer-vpc"]
  }
}

# Data sources to fetch subnets by tag
data "aws_subnet" "packer_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["packer-subnet-1"]
  }
}

data "aws_subnet" "packer_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["packer-subnet-2"]
  }
}

# Data source to fetch security group for HTTP (port 80)
data "aws_security_group" "packer_sg_http" {
  filter {
    name   = "tag:Name"
    values = ["packer-sg-http"]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

# Data source to fetch security group for RDP (port 3389)
data "aws_security_group" "packer_sg_rdp" {
  filter {
    name   = "tag:Name"
    values = ["packer-sg-rdp"]
  }

  vpc_id = data.aws_vpc.packer_vpc.id
}

data "aws_ami" "latest_games_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["games_ami*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["self"] # or use the actual AWS Account ID if needed
}

