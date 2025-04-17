############################################
# EC2 INSTANCE: GAMES SERVER DEPLOYMENT
############################################

resource "aws_instance" "games_server" {
  ami           = data.aws_ami.latest_games_ami.id     # Use the latest custom AMI that starts with "games_ami"
  instance_type = "t3.micro"                            # Instance type: burstable small instance (1 vCPU, 1 GiB RAM)

  # Network placement
  subnet_id = data.aws_subnet.packer_subnet_1.id        # Launch in the first public subnet
  vpc_security_group_ids = [                            # Attach multiple security groups for traffic control
    data.aws_security_group.packer_sg_http.id,          # Allow inbound HTTP (port 80)
    data.aws_security_group.packer_sg_https.id,         # Allow inbound HTTPS (port 443)
    data.aws_security_group.packer_sg_ssh.id            # Allow inbound SSH (port 22)
  ]

  associate_public_ip_address = true                    # Automatically assign a public IP on launch (for external access)

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  # Attach IAM instance profile that allows SSM access (for remote management via AWS Systems Manager)

  ############################################
  # USER DATA SCRIPT: INITIAL BOOT CONFIGURATION
  ############################################

  user_data = templatefile("${path.module}/scripts/userdata.sh", {
      ami_name = data.aws_ami.latest_games_ami.name
  })

  ############################################
  # INSTANCE TAGGING
  ############################################

  tags = {
    Name = "games-ec2-instance"                         # Assign instance a Name tag for easier identification
  }
}
