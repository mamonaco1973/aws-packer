
# Security Group for HTTP Traffic: Allows inbound HTTP access (port 80) and unrestricted outbound traffic
resource "aws_security_group" "packer_sg_http" {
  name        = "packer-sg-http"                     # Security group name
  description = "Security group to allow port 80 access and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                # Associate with the specified VPC

  # Ingress Rule: Allows inbound HTTP (TCP on port 80) from any IP address
  ingress {
    from_port   = 80                                 # HTTP port
    to_port     = 80                                 # HTTP port
    protocol    = "tcp"                              # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                      # WARNING: Open to all. Restrict in production!
  }

  

  # Egress Rule: Allows all outbound traffic to any IP address and port
  egress {
    from_port   = 0                                  # All ports
    to_port     = 0                                  # All ports
    protocol    = "-1"                               # All protocols
    cidr_blocks = ["0.0.0.0/0"]                      # WARNING: Unrestricted outbound traffic
  }

  tags = {
    Name          = "packer-sg-http"                  # Tag for resource identification
  }
}


# Security Group for HTTPS Traffic: Allows inbound HTTPS access (port 443) and unrestricted outbound traffic
resource "aws_security_group" "packer_sg_https" {
  name        = "packer-sg-https"                     # Security group name
  description = "Security group to allow port 443 access and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                # Associate with the specified VPC

  # Ingress Rule: Allows inbound HTTP (TCP on port 443) from any IP address
  ingress {
    from_port   = 443                                # HTTP port
    to_port     = 443                                # HTTP port
    protocol    = "tcp"                              # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                      # WARNING: Open to all. Restrict in production!
  }

  

  # Egress Rule: Allows all outbound traffic to any IP address and port
  egress {
    from_port   = 0                                  # All ports
    to_port     = 0                                  # All ports
    protocol    = "-1"                               # All protocols
    cidr_blocks = ["0.0.0.0/0"]                      # WARNING: Unrestricted outbound traffic
  }

  tags = {
    Name          = "packer-sg-https"                  # Tag for resource identification
  }
}


# Security Group for RDP Traffic: Allows inbound RDP access (port 3389) and unrestricted outbound traffic

resource "aws_security_group" "packer_sg_rdp" {
  name        = "packer-sg-rdp"                     # Security group name
  description = "Security group to allow port 3389 and open all outbound traffic"
  vpc_id      = aws_vpc.packer-vpc.id                # Associate with the specified VPC

  # Ingress Rule: Allows inbound HTTPS (TCP on port 443) from any IP address
  ingress {
    from_port   = 3389                                # RDP port
    to_port     = 3389                                # RDP port
    protocol    = "tcp"                               # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                       # WARNING: Open to all. Restrict in production!
  }

  
  # Egress Rule: Allows all outbound traffic to any IP address and port
  egress {
    from_port   = 0                                  # All ports
    to_port     = 0                                  # All ports
    protocol    = "-1"                               # All protocols
    cidr_blocks = ["0.0.0.0/0"]                      # WARNING: Unrestricted outbound traffic
  }

  tags = {
    Name          = "packer-sg-rdp"                 # Tag for resource identification
  }
}


resource "random_password" "generated" {
  length  = 24
  special = false  # Alphanumeric only (no special characters)
}

resource "local_file" "password_file" {
  filename = "../password.txt"
  content  = random_password.generated.result
}
