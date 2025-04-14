# Application Load Balancer (ALB) definition
resource "aws_lb" "flask_alb" {
  name               = "flask-alb"                 # Name of the ALB
  internal           = false                       # ALB is internet-facing
  load_balancer_type = "application"               # Load balancer type: Application
  security_groups    = [aws_security_group.flask_sg_http.id]  
                                                   # Associated security group
  subnets            = [                           # Subnets for ALB deployment
    aws_subnet.flask-subnet-1.id,
    aws_subnet.flask-subnet-2.id
  ]

  tags = {
    Name          = "flask-alb"                   # Tag for resource identification
    ResourceGroup = "flask-asg-rg"                # Tag for resource manager
  }
}

# Target Group for the ALB
resource "aws_lb_target_group" "fask_alb_tg" {
  name     = "flask-alb-tg"                       # Target group name
  port     = 8000                                 # Target group port
  protocol = "HTTP"                               # Target group protocol
  vpc_id   = aws_vpc.flask-vpc.id                 # VPC ID for the target group

  # Health check configuration
  health_check {
    path                = "/gtg"                  # Health check path
    interval            = 10                      # Interval between checks (seconds)
    timeout             = 5                       # Timeout for each check (seconds)
    healthy_threshold   = 3                       # Threshold for marking healthy
    unhealthy_threshold = 2                       # Threshold for marking unhealthy
    matcher             = "200,300-310"           # Expected HTTP response codes
  }

  tags = {
    Name          = "flask-alb-tg"                # Tag for resource identification
    ResourceGroup = "flask-asg-rg"                # Tag for resource manager
  }
}

# HTTP listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.flask_alb.arn        # ARN of the associated ALB
  port              = 80                          # Listener port
  protocol          = "HTTP"                      # Listener protocol

  # Default action configuration
  default_action {
    type             = "forward"                  # Action type: forward traffic
    target_group_arn = aws_lb_target_group.fask_alb_tg.arn  
                                                  # Target group ARN
  }
}
