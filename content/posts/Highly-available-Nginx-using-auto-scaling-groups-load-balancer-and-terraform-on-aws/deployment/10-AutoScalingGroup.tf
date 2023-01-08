resource "aws_autoscaling_group" "asg" {
  name                      = "${var.Name-Tag} autoscaling-group"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.lc.id
  vpc_zone_identifier       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tag {
    key                 = "Name"
    value               = "${var.Name-Tag} autoscaling-group"
    propagate_at_launch = true
  }
  # All instances created with the asg will be placed into the alb target group
  target_group_arns = [aws_alb_target_group.target_group.arn]
}