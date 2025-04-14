# CloudWatch Alarm to scale up the Auto Scaling Group when CPU utilization exceeds 80%
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "HighCPUUtilization"                      # Alarm name
  comparison_operator = "GreaterThanThreshold"                    # Trigger when metric exceeds threshold
  evaluation_periods  = 2                                         # Consecutive periods to breach threshold
  metric_name         = "CPUUtilization"                          # Metric to monitor
  namespace           = "AWS/EC2"                                 # AWS namespace for the metric
  period              = 30                                        # Duration of each evaluation period (seconds)
  statistic           = "Average"                                 # Aggregation type for the metric
  threshold           = 60                                        # Threshold for triggering the alarm
  alarm_description   = "Scale up if CPUUtilization > 60% for 1 minute"
  actions_enabled     = true                                      # Enable alarm actions

  # Metric dimensions to associate the alarm with the Auto Scaling Group
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.flask_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]    # Action to execute when alarm triggers
}

# Scaling policy to increase the number of instances in the Auto Scaling Group
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"                      # Scaling policy name
  scaling_adjustment     = 1                                      # Number of instances to add
  adjustment_type        = "ChangeInCapacity"                     # Scaling method: add fixed number
  cooldown               = 120                                    # Cooldown period before next scaling action
  autoscaling_group_name = aws_autoscaling_group.flask_asg.name   # Associated Auto Scaling Group
}

# CloudWatch Alarm to scale down the Auto Scaling Group when CPU utilization drops below 5%
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "LowCPUUtilization"                       # Alarm name
  comparison_operator = "LessThanThreshold"                       # Trigger when metric falls below threshold
  evaluation_periods  = 10                                        # Consecutive periods to breach threshold
  metric_name         = "CPUUtilization"                          # Metric to monitor
  namespace           = "AWS/EC2"                                 # AWS namespace for the metric
  period              = 30                                        # Duration of each evaluation period (seconds)
  statistic           = "Average"                                 # Aggregation type for the metric
  threshold           = 60                                        # Threshold for triggering the alarm
  alarm_description   = "Scale down if CPUUtilization < 60% for 5 minutes"
  actions_enabled     = true                                      # Enable alarm actions

  # Metric dimensions to associate the alarm with the Auto Scaling Group
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.flask_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]  # Action to execute when alarm triggers
}

# Scaling policy to decrease the number of instances in the Auto Scaling Group
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"                    # Scaling policy name
  scaling_adjustment     = -1                                     # Number of instances to remove
  adjustment_type        = "ChangeInCapacity"                     # Scaling method: remove fixed number
  cooldown               = 120                                    # Cooldown period before next scaling action
  autoscaling_group_name = aws_autoscaling_group.flask_asg.name   # Associated Auto Scaling Group
}

# Auto Scaling Group (ASG) definition
resource "aws_autoscaling_group" "flask_asg" {
  # Launch template for EC2 instance configuration
  launch_template {
    id      = aws_launch_template.flask_launch_template.id    # Launch template ID
    version = "$Latest"                                       # Latest version of the launch template
  }

  name                   = "flask-asg"                        # Auto Scaling Group name
  vpc_zone_identifier    = [                                  # Subnets for the ASG
    aws_subnet.flask-subnet-1.id,
    aws_subnet.flask-subnet-2.id
  ]
  desired_capacity          = var.asg_instances                   # Desired number of instances
  max_size                  = 4                                   # Maximum number of instances
  min_size                  = var.asg_instances                   # Minimum number of instances
  health_check_type         = "ELB"                               # Health check type (ELB-based)
  health_check_grace_period = 30                                  # Grace period for instance health check
  default_cooldown          = 30                                  # Cooldown period between scaling actions
  default_instance_warmup   = 60                                  # Warmup period for new instances

  target_group_arns = [aws_lb_target_group.fask_alb_tg.arn]      #  Associated ALB target group
  
  # Tags for instances created by the ASG
  tag {
    key                 = "Name"                                  # Tag key
    value               = "flask-asg"                             # Tag value
    propagate_at_launch = false                                   # Apply tag at instance launch
  }

   # Tags for instances created by the ASG
  tag {
    key                 = "ResourceGroup"                         # Tag key
    value               = "flask-asg-rg"                          # Tag value
    propagate_at_launch = true                                    # Apply tag at instance launch
  }
}
