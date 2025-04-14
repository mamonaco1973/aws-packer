# EC2 Instances and Launch Template for Load Balancer Integration

# Instance Profile for attaching the IAM Role to EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"                  # Name of the instance profile
  role = aws_iam_role.flask_ec2_role.name        # Associated IAM role
}

# Launch Template for Autoscaling Group
resource "aws_launch_template" "flask_launch_template" {
  name        = "flask-launch-template"        # Launch template name
  description = "Launch template for autoscaling"

  # Root volume configuration
  block_device_mappings {
    device_name = "/dev/xvda"                    # Root device name

    ebs {
      delete_on_termination = true               # Delete volume on instance termination
      volume_size           = 8                  # Volume size (GiB)
      volume_type           = "gp3"              # Volume type
      encrypted             = true               # Enable encryption
    }
  }

  # Network settings
  network_interfaces {
    associate_public_ip_address = true           # Assign public IP
    delete_on_termination       = true           # Delete interface on instance termination
    security_groups             = [              # Security groups for network access
      aws_security_group.flask_sg_https.id,
      aws_security_group.flask_sg_flask.id
    ]
  }

  # IAM instance profile
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  # Instance details
  instance_type = "t2.micro"                     # Instance type
  #key_name     = "flask-key"                    # SSH key pair
  image_id      = var.default_ami                # AMI ID (using variable for flexibility)

  # Bootstrap script
  user_data = base64encode(file("./scripts/bootstrap.sh"))

   tags = {
    Name          = "flask-launch-template"       # Tag for resource identification
    ResourceGroup = "flask-asg-rg"                # Tag for resource manager
  }

  # Tag specifications
  tag_specifications {
    resource_type = "instance"                   # Tag for EC2 instances
    tags = {
      Name = "flask-lt-instance"                 # Tag name
      ResourceGroup = "flask-asg-rg"
    }
  }
}
