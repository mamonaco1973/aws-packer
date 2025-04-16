############################################
# EC2 INSTANCE: DESKTOP SERVER DEPLOYMENT
############################################

resource "aws_instance" "desktop_server" {
  ami           = data.aws_ami.latest_desktop_ami.id   # Use the latest custom AMI that starts with "desktop_ami"
  instance_type = "t3.medium"                          

  # Network placement
  subnet_id = data.aws_subnet.packer_subnet_1.id        # Launch in the first public subnet
  vpc_security_group_ids = [                            # Attach multiple security groups for traffic control
    data.aws_security_group.packer_sg_https.id,         # Allow inbound HTTPS (port 443)
    data.aws_security_group.packer_sg_rdp               # Allow inbound RDP (port 3389)
  ]

  associate_public_ip_address = true                    # Automatically assign a public IP on launch (for external access)

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  # Attach IAM instance profile that allows SSM access (for remote management via AWS Systems Manager)

  ############################################
  # USER DATA SCRIPT: INITIAL BOOT
  ############################################

  user_data = <<-EOF
               <powershell>
               powershell.exe -ExecutionPolicy Bypass -File "C:\mcloud\boot.ps1"
               </powershell>
               EOF

  ############################################
  # INSTANCE TAGGING
  ############################################

  tags = {
    Name = "desktop-ec2-instance"                         # Assign instance a Name tag for easier identification
  }
}
