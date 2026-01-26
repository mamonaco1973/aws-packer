# ==============================================================================
# EC2 INSTANCE: DESKTOP SERVER DEPLOYMENT
# ==============================================================================
#
# This resource deploys a desktop server EC2 instance using the most recent
# custom Windows AMI produced by the Packer desktop image pipeline.
#
# The instance is launched into a public subnet and configured for remote
# access via RDP and AWS Systems Manager.
# ==============================================================================

resource "aws_instance" "desktop_server" {
  # Use the latest custom desktop AMI discovered via data source lookup.
  ami = data.aws_ami.latest_desktop_ami.id

  # Instance type sized for desktop workloads with additional CPU and memory.
  instance_type = "t3.medium"

  # --------------------------------------------------------------------------
  # Network placement
  # --------------------------------------------------------------------------
  # Launch the instance in the second public subnet.
  subnet_id = data.aws_subnet.packer_subnet_2.id

  # Attach security groups required for desktop access.
  vpc_security_group_ids = [
    data.aws_security_group.packer_sg_https.id,
    data.aws_security_group.packer_sg_rdp.id
  ]

  # Assign a public IP address to allow external connectivity.
  associate_public_ip_address = true

  # --------------------------------------------------------------------------
  # IAM configuration
  # --------------------------------------------------------------------------
  # Attach an IAM instance profile to enable AWS Systems Manager access.
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # --------------------------------------------------------------------------
  # USER DATA: INITIAL BOOTSTRAP CONFIGURATION
  # --------------------------------------------------------------------------
  # Execute a PowerShell startup script for instance-specific configuration.
  user_data = templatefile("${path.module}/scripts/userdata.ps1", {
    ami_name = data.aws_ami.latest_desktop_ami.name
  })

  # --------------------------------------------------------------------------
  # INSTANCE TAGGING
  # --------------------------------------------------------------------------
  tags = {
    # Name tag for identification in the AWS console.
    Name = "desktop-ec2-instance"
  }
}
