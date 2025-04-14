# Security Group for SSH Traffic: Allows inbound SSH access (port 22) and unrestricted outbound traffic
resource "aws_security_group" "flask_sg_ssh" {
  name        = "flask-sg-ssh"                      # Security group name
  description = "Security group to allow SSH access and open all outbound traffic"
  vpc_id      = aws_vpc.flask-vpc.id                # Associate with the specified VPC

  # Ingress Rule: Allows inbound SSH (TCP on port 22) from any IP address
  ingress {
    from_port   = 22                                 # SSH port
    to_port     = 22                                 # SSH port
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
    Name          = "flash-sg-ssh"                   # Tag for resource identification
  }
}

# Security Group for HTTP Traffic: Allows inbound HTTP access (port 80) and unrestricted outbound traffic
resource "aws_security_group" "flask_sg_http" {
  name        = "flask-sg-http"                     # Security group name
  description = "Security group to allow port 80 access and open all outbound traffic"
  vpc_id      = aws_vpc.flask-vpc.id                # Associate with the specified VPC

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
    Name          = "flask-sg-http"                  # Tag for resource identification
  }
}

# Security Group for HTTPS Traffic: Allows inbound HTTPS access (port 443) and unrestricted outbound traffic
# Added to support SSM

resource "aws_security_group" "flask_sg_https" {
  name        = "flask-sg-https"                     # Security group name
  description = "Security group to allow port 443 access and open all outbound traffic"
  vpc_id      = aws_vpc.flask-vpc.id                # Associate with the specified VPC

  # Ingress Rule: Allows inbound HTTPS (TCP on port 443) from any IP address
  ingress {
    from_port   = 443                                 # HTTPS port
    to_port     = 443                                 # HTTPS port
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
    Name          = "flask-sg-https"                 # Tag for resource identification
  }
}

# Security Group for Flask Traffic: Allows inbound Flask traffic (port 8000) and unrestricted outbound traffic
resource "aws_security_group" "flask_sg_flask" {
  name        = "flask-sg-flask"                     # Security group name
  description = "Security group to allow port 8000 flask access and open all outbound traffic"
  vpc_id      = aws_vpc.flask-vpc.id             # Associate with the specified VPC

  # Ingress Rule: Allows inbound Flask traffic (TCP on port 8000) from any IP address
  ingress {
    from_port   = 8000                               # Flask port
    to_port     = 8000                               # Flask port
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
    Name = "flask-sg-flask"                         # Tag for resource identification
  }
}
