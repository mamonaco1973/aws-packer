# ==============================================================================
# VPC CONFIGURATION FOR PACKER INFRASTRUCTURE
# ==============================================================================
#
# This module provisions a minimal public VPC layout suitable for running Packer
# builds that require outbound internet access (package installs, updates, etc).
#
# Topology:
# - One VPC (10.0.0.0/24)
# - One Internet Gateway
# - One public route table with a default route to the IGW
# - Two public subnets across two AZs
# - Route table associations for both subnets
# ==============================================================================

# ==============================================================================
# VPC
# ==============================================================================

resource "aws_vpc" "packer-vpc" {
  # Primary VPC CIDR block used for all subnets in this module.
  cidr_block = "10.0.0.0/24"

  # Enable DNS features so instances can resolve and receive DNS hostnames.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    # Human-readable name for identification in the AWS console.
    Name = "packer-vpc"

    # Optional logical grouping tag (not an AWS-native resource group).
    ResourceGroup = "packer-asg-rg"
  }
}

# ==============================================================================
# INTERNET GATEWAY
# ==============================================================================

resource "aws_internet_gateway" "packer-igw" {
  # Attach the Internet Gateway to the VPC to enable internet routing.
  vpc_id = aws_vpc.packer-vpc.id

  tags = {
    # Name tag for identification in the AWS console.
    Name = "packer-igw"
  }
}

# ==============================================================================
# ROUTING: PUBLIC ROUTE TABLE + DEFAULT ROUTE
# ==============================================================================

resource "aws_route_table" "public" {
  # Route table associated with the VPC for public subnet routing.
  vpc_id = aws_vpc.packer-vpc.id

  tags = {
    # Name tag for identification in the AWS console.
    Name = "public-route-table"
  }
}

resource "aws_route" "default_route" {
  # Bind this route to the public route table.
  route_table_id = aws_route_table.public.id

  # Default route for all IPv4 traffic destined for the internet.
  destination_cidr_block = "0.0.0.0/0"

  # Send default traffic to the Internet Gateway.
  gateway_id = aws_internet_gateway.packer-igw.id
}

# ==============================================================================
# PUBLIC SUBNETS
# ==============================================================================

resource "aws_subnet" "packer-subnet-1" {
  # Place subnet 1 in the VPC.
  vpc_id = aws_vpc.packer-vpc.id

  # First /26 block within the /24 (64 total addresses, fewer usable).
  cidr_block = "10.0.0.0/26"

  # Assign public IPs by default for instances launched in this subnet.
  map_public_ip_on_launch = true

  # Availability Zone placement for subnet 1.
  availability_zone = "us-east-2a"

  tags = {
    # Name tag for identification in the AWS console.
    Name = "packer-subnet-1"
  }
}

resource "aws_subnet" "packer-subnet-2" {
  # Place subnet 2 in the VPC.
  vpc_id = aws_vpc.packer-vpc.id

  # Second /26 block within the /24 (64 total addresses, fewer usable).
  cidr_block = "10.0.0.64/26"

  # Assign public IPs by default for instances launched in this subnet.
  map_public_ip_on_launch = true

  # Availability Zone placement for subnet 2.
  availability_zone = "us-east-2b"

  tags = {
    # Name tag for identification in the AWS console.
    Name = "packer-subnet-2"
  }
}

# ==============================================================================
# ROUTE TABLE ASSOCIATIONS
# ==============================================================================

resource "aws_route_table_association" "public_rta_1" {
  # Associate subnet 1 with the public route table.
  subnet_id = aws_subnet.packer-subnet-1.id

  # Use the route table that contains the default IGW route.
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_rta_2" {
  # Associate subnet 2 with the public route table.
  subnet_id = aws_subnet.packer-subnet-2.id

  # Use the route table that contains the default IGW route.
  route_table_id = aws_route_table.public.id
}
