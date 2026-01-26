# ==============================================================================
# EC2 INSTANCE: GAMES SERVER DEPLOYMENT
# ==============================================================================
#
# This resource deploys a games server EC2 instance using the most recent
# custom AMI produced by the Packer build pipeline.
#
# The instance is launched into a public subnet with internet access and
# attaches security groups required for web and administrative traffic.
# ==============================================================================

resource "aws_instance" "games_server" {
  # Use the latest custom games AMI discovered via data source lookup.
  ami = data.aws_ami.latest_games_ami.id

  # Burstable instance type suitable for lightweight game workloads.
  instance_type = "t3.micro"

  # --------------------------------------------------------------------------
  # Network placement
  # --------------------------------------------------------------------------
  # Launch the instance in the first public subnet.
  subnet_id = data.aws_subnet.packer_subnet_1.id

  # Attach security groups controlling inbound access.
  vpc_security_group_ids = [
    data.aws_security_group.packer_sg_http.id,
    data.aws_security_group.packer_sg_https.id,
    data.aws_security_group.packer_sg_ssh.id
  ]

  # Assign a public IP address for external access.
  associate_public_ip_address = true

  # --------------------------------------------------------------------------
  # IAM configuration
  # --------------------------------------------------------------------------
  # Attach an IAM instance profile that enables AWS Systems Manager access.
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # --------------------------------------------------------------------------
  # USER DATA: INITIAL BOOTSTRAP CONFIGURATION
  # --------------------------------------------------------------------------
  # Execute a startup script to perform instance-specific configuration.
  user_data = templatefile("${path.module}/scripts/userdata.sh", {
    ami_name = data.aws_ami.latest_games_ami.name
  })

  # --------------------------------------------------------------------------
  # INSTANCE TAGGING
  # --------------------------------------------------------------------------
  tags = {
    # Name tag for identification in the AWS console.
    Name = "games-ec2-instance"
  }
}
