resource "aws_instance" "games_server" {
  ami           = data.aws_ami.latest_games_ami.id
  instance_type = "t3.micro"

  subnet_id              = data.aws_subnet.packer_subnet_1.id
  vpc_security_group_ids = [data.aws_security_group.packer_sg_http.id,
                            data.aws_security_group.packer_sg_https.id,
                            data.aws_security_group.packer_sg_ssh.id]

  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Enable SSH password authentication
              sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
              systemctl restart sshd
              EOF

  tags = {
    Name = "games-ec2-instance"
  }
}
