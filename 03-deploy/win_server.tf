############################################
# EC2 INSTANCE: DESKTOP SERVER DEPLOYMENT
############################################

resource "aws_instance" "desktop_server" {
  ami           = data.aws_ami.latest_desktop_ami.id   # Use the latest custom AMI that starts with "desktop_ami"
  instance_type = "t3.medium"                           # Instance type with more memory and CPU (2 vCPUs, 4 GiB RAM)

  # Network placement
  subnet_id = data.aws_subnet.packer_subnet_2.id        # Launch in the first public subnet
  vpc_security_group_ids = [                            # Attach multiple security groups for traffic control
    data.aws_security_group.packer_sg_https.id,         # Allow inbound HTTPS (port 443)
    data.aws_security_group.packer_sg_rdp.id            # Allow inbound RDP (port 3389)
  ]

  associate_public_ip_address = true                    # Automatically assign a public IP on launch (for external access)

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  # Attach IAM instance profile that allows SSM access (for remote management via AWS Systems Manager)

  ############################################
  # USER DATA SCRIPT: INITIAL BOOT CONFIGURATION
  ############################################

  user_data = templatefile("${path.module}/scripts/userdata.ps1", {
        ami_name = data.aws_ami.latest_desktop_ami.name
  })

  ############################################
  # INSTANCE TAGGING
  ############################################

  tags = {
    Name = "desktop-ec2-instance"                         # Assign instance a Name tag for easier identification
  }
}
