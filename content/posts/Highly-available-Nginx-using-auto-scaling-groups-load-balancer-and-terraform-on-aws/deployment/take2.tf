# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# provider "aws" {
#   region = "eu-west-2"
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }


# VPC
# resource "aws_vpc" "vpc" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"
#   tags = {
#     Name = "terraform tut"
#   }
# }

# IG
# resource "aws_internet_gateway" "ig" {
#   vpc_id = aws_vpc.vpc.id
# }

# Subnet 1
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = data.aws_availability_zones.available.names[0]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public subnet 1"
#   }
# }

# Subnet 2
# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = data.aws_availability_zones.available.names[1]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public subnet 2"
#   }
# }

# resource "aws_route_table" "rt" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.ig.id
#   }

#   tags = {
#     Name = "terraform tut rt"
#   }
# }

# resource "aws_route_table_association" "rt_ass_public_subnet_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.rt.id
# }

# resource "aws_route_table_association" "rt_ass_public_subnet_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.rt.id
# }


# ===========================

# resource "aws_security_group" "web_sg" {
#   name   = "web sg"
#   vpc_id = aws_vpc.vpc.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow all outbound traffic.
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     "Name" = "web sg"
#   }
# }


# resource "aws_instance" "my_instance_1" {
#   ami           = "ami-084e8c05825742534"
#   instance_type = "t3.micro"
#   subnet_id = aws_subnet.public_subnet_1.id
#   security_groups = [aws_security_group.web_sg.id]

#   user_data = <<EOF
#   #!/bin/bash
#   sudo yum update -y
#   sudo amazon-linux-extras install nginx1 -y 
#   sudo systemctl enable nginx
#   sudo systemctl start nginx
#   EOF

#   tags = {
#     Name = "HelloWorld"
#   }
# }



# resource "aws_launch_configuration" "lc" {
#   name            = "my-lc"
#   image_id        = "ami-084e8c05825742534"
#   instance_type   = "t2.micro"
#   key_name        = "tutorials"
#   user_data       = <<EOF
#   #!/bin/bash
#   sudo yum update -y
#   sudo amazon-linux-extras install nginx1 -y 
#   sudo systemctl enable nginx
#   sudo systemctl start nginx
#   EOF
#   security_groups = [aws_security_group.web_sg.id]
# }

# resource "aws_autoscaling_group" "asg" {
#   name                      = "my-asg"
#   min_size                  = 1
#   max_size                  = 4
#   desired_capacity          = 2
#   health_check_grace_period = 300
#   health_check_type         = "EC2"
#   launch_configuration      = aws_launch_configuration.lc.id
#   vpc_zone_identifier       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
#   tag {
#     key                 = "Name"
#     value               = "my-asg"
#     propagate_at_launch = true
#   }
#   # All instances created with the asg will be placed into the alb target group
#   target_group_arns = [aws_alb_target_group.target_group.arn]
# }

# application load balancer
# resource "aws_lb" "alb" {
#   name               = "test-lb-tf"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.web_sg.id]
#   subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

#   tags = {
#     "Name" = "Application LB"
#   }
# }


# target group
# resource "aws_alb_target_group" "target_group" {
#   name     = "terraform-example-alb-target"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc.id
#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# target group attachment - not required


# listener for http
# resource "aws_alb_listener" "listener_http" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_alb_target_group.target_group.arn
#     type             = "forward"
#   }
# }