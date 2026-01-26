# ==============================================================================
# SECURITY GROUPS FOR PACKER BUILD INFRASTRUCTURE
# ==============================================================================
#
# These security groups are intended for Packer build instances that require
# temporary network access during image creation.
#
# Notes:
# - Ingress rules are intentionally permissive for build-time convenience.
# - These rules are NOT suitable for production workloads.
# - Restrict CIDR ranges or remove rules entirely in hardened environments.
# ==============================================================================

# ==============================================================================
# SECURITY GROUP: HTTP (PORT 80)
# ==============================================================================

resource "aws_security_group" "packer_sg_http" {
  # Security group allowing inbound HTTP traffic.
  name        = "packer-sg-http"
  description = "Allow inbound HTTP and unrestricted outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id

  # Allow inbound HTTP traffic from any IPv4 address.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic for package installs and updates.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "packer-sg-http"
  }
}

# ==============================================================================
# SECURITY GROUP: HTTPS (PORT 443)
# ==============================================================================

resource "aws_security_group" "packer_sg_https" {
  # Security group allowing inbound HTTPS traffic.
  name        = "packer-sg-https"
  description = "Allow inbound HTTPS and unrestricted outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id

  # Allow inbound HTTPS traffic from any IPv4 address.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic for updates and external access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "packer-sg-https"
  }
}

# ==============================================================================
# SECURITY GROUP: SSH (PORT 22)
# ==============================================================================

resource "aws_security_group" "packer_ssh" {
  # Security group allowing inbound SSH access.
  name        = "packer-sg-ssh"
  description = "Allow inbound SSH and unrestricted outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id

  # Allow inbound SSH traffic from any IPv4 address.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic for provisioning and downloads.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "packer-sg-ssh"
  }
}

# ==============================================================================
# SECURITY GROUP: RDP (PORT 3389)
# ==============================================================================

resource "aws_security_group" "packer_sg_rdp" {
  # Security group allowing inbound RDP access.
  name        = "packer-sg-rdp"
  description = "Allow inbound RDP and unrestricted outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id

  # Allow inbound RDP traffic from any IPv4 address.
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic for provisioning and system updates.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "packer-sg-rdp"
  }
}
