############################################
# SECURITY GROUP: HTTP (PORT 80)
############################################

resource "aws_security_group" "packer_sg_http" {
  name        = "packer-sg-http"                           # Name of the security group
  description = "Security group to allow port 80 access and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                      # Associate SG with the packer VPC

  # Ingress Rule — Allow HTTP traffic from anywhere
  ingress {
    from_port   = 80                                       # Starting port — HTTP
    to_port     = 80                                       # Ending port — HTTP
    protocol    = "tcp"                                    # TCP protocol required for HTTP
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Open to all IPv4 addresses — not secure for production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port   = 0                                        # Start of port range (0 = all)
    to_port     = 0                                        # End of port range (0 = all)
    protocol    = "-1"                                     # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Unrestricted outbound access
  }

  tags = {
    Name = "packer-sg-http"                                # Name tag for easier lookup
  }
}

############################################
# SECURITY GROUP: HTTPS (PORT 443)
############################################

resource "aws_security_group" "packer_sg_https" {
  name        = "packer-sg-https"                          # Name of the security group
  description = "Security group to allow port 443 access and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                      # Associate SG with the packer VPC

  # Ingress Rule — Allow HTTPS traffic from anywhere
  ingress {
    from_port   = 443                                      # Starting port — HTTPS
    to_port     = 443                                      # Ending port — HTTPS
    protocol    = "tcp"                                    # TCP protocol required for HTTPS
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Open to all IPv4 addresses — not secure for production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port   = 0                                        # Start of port range (0 = all)
    to_port     = 0                                        # End of port range (0 = all)
    protocol    = "-1"                                     # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Unrestricted outbound access
  }

  tags = {
    Name = "packer-sg-https"                               # Name tag for easier lookup
  }
}

############################################
# SECURITY GROUP: SSH (PORT 22)
############################################

resource "aws_security_group" "packer_ssh" {
  name        = "packer-sg-ssh"                            # Name of the security group
  description = "Security group to allow port 22 access and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                      # Associate SG with the packer VPC

  # Ingress Rule — Allow SSH access from anywhere
  ingress {
    from_port   = 22                                       # Starting port — SSH
    to_port     = 22                                       # Ending port — SSH
    protocol    = "tcp"                                    # TCP protocol required for SSH
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Open to all IPv4 addresses — not secure for production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port   = 0                                        # Start of port range (0 = all)
    to_port     = 0                                        # End of port range (0 = all)
    protocol    = "-1"                                     # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Unrestricted outbound access
  }

  tags = {
    Name = "packer-sg-ssh"                                 # Name tag for easier lookup
  }
}

############################################
# SECURITY GROUP: RDP (PORT 3389)
############################################

resource "aws_security_group" "packer_sg_rdp" {
  name        = "packer-sg-rdp"                            # Name of the security group
  description = "Security group to allow port 3389 and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                      # Associate SG with the packer VPC

  # Ingress Rule — Allow RDP access from anywhere
  ingress {
    from_port   = 3389                                     # Starting port — RDP
    to_port     = 3389                                     # Ending port — RDP
    protocol    = "tcp"                                    # TCP protocol required for RDP
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Open to all IPv4 addresses — not secure for production
  }

  # Egress Rule — Allow all outbound traffic
  egress {
    from_port   = 0                                        # Start of port range (0 = all)
    to_port     = 0                                        # End of port range (0 = all)
    protocol    = "-1"                                     # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]                            # ⚠️ Unrestricted outbound access
  }

  tags = {
    Name = "packer-sg-rdp"                                 # Name tag for easier lookup
  }
}
