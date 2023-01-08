resource "aws_launch_configuration" "lc" {
  name            = "${var.Name-Tag} launch-configration"
  image_id        = var.ami
  instance_type   = var.instance-type
  key_name        = var.key-pair-name
  user_data       = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install nginx1 -y 
  sudo systemctl enable nginx
  sudo systemctl start nginx
  EOF
  security_groups = [aws_security_group.web_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}