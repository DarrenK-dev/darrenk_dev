---
title: "Highly available Nginx using Auto
Scaling Group, Load Balancer and Terraform on AWS"
date: 2022-12-29T20:46:41Z
draft: false
# type: hidden

weight: 3
# aliases: ["/first"]
tags: ["first"]
author: "Me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false

hidemeta: false
comments: false
description: "Desc Text."
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---


# Summary

In this tutorial we will be using terraform to build out our infrastructure on aws.

The goal of this tutorials is to provision a highly available application (simple nginx website serving an index.html file) distributed across two availability zones on aws. The website will be hosted on amazon linux 2 instances and will be provisioned using a launch configuration and auto scaling group. For our clients to access the application we will provision an application load balancer to distribute the traffic in a 'round-robin' approach to one of the running instances, this will offer good availability if one instance becomes inactive or we loose access to an availability zone (because the traffic will be re-directed to the other instance). This tutorial is a good starting point to cover auto scaling groups, load balancers and basic launch configurations. The application is simple by design as the concepts covered in this tutorial are my focus.


I will be breaking down the terraform code into smaller descriptive files. There will be no modules used or created, all code will be written from scratch with the aid of a variables.tf file.

___
# 01-Providers.tf

Create a new file called `01-Providers.tf` and enter the following code.

```
# Part 1
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Part 2
provider "aws" {
  profile = "default"
  region = "eu-west-2"
}
```

The first block, "terraform", declares the required providers for this configuration. In this case, it specifies that the AWS provider, developed by HashiCorp, is required, and it should be version 4.0 or newer.

The second block, "provider", specifies the provider configuration for AWS. It sets the AWS CLI profile to "default" and the region to "eu-west-2", which is the region code for the London region.

Together, these blocks declare that the configuration requires the AWS provider, and it should use the "default" profile in the London region to manage resources in AWS.

___
# 02-Variables.tf
```
data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_cidr" {
  description = "This is the cidr_block for our VPC we will provision."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "This is the cidr_block for the first public subnet we will provision"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "This is the cidr_block for the second public subnet we will provision"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ami" {
  description = "Ami for Amazon Linux 2 ec2 instance"
  type        = string
  default     = "ami-084e8c05825742534"
}

variable "key-pair-name" {
  description = "The ec2 key-pair name used to ssh into ec2 instances, this must already exist"
  type        = string
  default     = "tutorials"
}

variable "instance-type" {
  description = "The type of ec2 instance (i.e. it's size) to be used within the launch configuration"
  type        = string
  default     = "t2.micro"
}

variable "Name-Tag" {
  description = "The Tag with the key of `Name` value. This will hepl identify resources provisioned from this IaC terraform tutorial viewed through the AWS management console."
  type        = string
  default     = "darrenk.dev tutorial"
}
``` 
The first block, "data", declares a data source. In this case, it is the "aws_availability_zones" data source, which retrieves a list of availability zones in a region. The "available" block specifies the name of the data source and sets the "state" argument to "available", which retrieves only available availability zones.

The following blocks, "variable", declare variables for the configuration. Each block includes a "description" argument to provide information about the variable, a "type" argument to specify the type of the variable (e.g. string, list, map), and a "default" argument to set a default value for the variable.

These variables can be used to parameterize the configuration, allowing it to be more flexible and reusable. For example, the "vpc_cidr" variable can be used to specify the CIDR block for a virtual private cloud (VPC) in AWS, while the "ami" variable can be used to specify the Amazon Machine Image (AMI) to use when launching Amazon Elastic Compute Cloud (EC2) instances. We will use all variables stored in this file throughout the tutorial, and if you want to change any you know where to find them - in the `02-Variables.tf` file.

___
# 03-VPC.tf

```
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    "Name" = "${var.Name-Tag} vpc"
  }
}
```
Amazon Virtual Private Cloud (Amazon VPC) enables you to launch Amazon Web Services (AWS) resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your on-premises data center, with the benefits of using the scalable infrastructure of AWS. It's always good practice to create a new VPC for a new project as you can isolate your resources from the public internet, and you can control the inbound and outbound network traffic to and from your resources. This can help you meet your compliance requirements and increase security. In the case of learning and tutorials you can separate your tutorial resources (where applicable) into a defined VPC making them easier to identify and manage - with that in mind let's create a VPC for our tutorial (code above).


We are using two variable in this file and they are used differently. The first variable is written `var.vpc_cidr` and the second like this `"${var.Name-Tag} vpc"`. The second type of use is ideal for string interpolation or concatenation, as you can see I have added the string " vpc" to the end of the variable - this will ultimately result in a string value of "darrenk.dev tutorial vpc". I had no need to concatenate any additional string to the first variable, so used a simple `var.` syntax followed by the name of the variable `var.vpc_cidr`. 

> Stop now and search for the `vpc_cidr` variables default value in the `02-Variables.tf` file (above) to see what value will be placed there - if you found "10.0.0.0/16" then you're correct.   

In short this code create a new VPC in the aws region specified, if we don't provide a region within the resource code then terraform will check in the provider block for aws, I placed this in the 01-Providers.tf file:   
```
provider "aws" {
  region = "eu-west-2" <-- this line
}
```

As you can see we specified the region as "eu-west-2". I've used this region as London is the closest region to me. It's good practice to use variables as it centralizes them (we know where to find them) and we can change them in a single place if required. I mean imagine having to search though 100s of files to change out all the regions if they were hard-coded! Much better to use variables and reference them throughout your code base.

___
# 04-InternetGateway.tf
```
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.Name-Tag} ig"
  }
}
```
Now we have a VPC we need to allow internet traffic in and out, by default a VPC is closed off from the internet. For this we need to create a resource called an internet gateway and attach it to the VPC we've just created. Just remember, if one or more resources contained within your VPC requires access to the internet then you'll need to create and attach one internet gateway to the VPC. *Note: You can not attach more than one VPC to an internet gateway.*

The block includes several arguments that are used to configure the internet gateway. The "vpc_id" argument specifies the ID of the VPC to which the internet gateway will be attached. In this case, it retrieves the ID of the VPC from the "aws_vpc" resource using the "vpc.id" attribute.
```
resource "aws_vpc" "vpc" { <-- this line
  ...
  ...code
}
````

> *Tip: Copy the first line of the resource (shown above), remove the resource and { then delete all ". Add a period between the two words. You can then add `.id` to the end to retrieve the id of that particular resource - look at the example below*

```
#1 
resource "aws_vpc" "vpc" {    //remove the resource word and {

#2
"aws_vpc" "vpc"               // remove the ""

#3
aws_vpc.vpc                   // add a period between the words

#4
aws_vpc.vpc.id                // add `.id` to the end if we want that resources id

```
The block also contains the tags block - this was explained before.

___
# 05-RouteTable.tf
```
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "${var.Name-Tag} rt"
  }
}
```
The code above is an Amazon Web Services (AWS) route table and the "aws_route_table" block specifies that it is managed by the AWS provider. The "rt" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the route table. The "vpc_id" argument specifies the ID of the VPC to which the route table will be associated. In this case, it retrieves the ID of the VPC from the "aws_vpc" resource using the "vpc.id" attribute (as I described in the Tip above).

The "route" block specifies a route for the route table. It includes a "cidr_block" argument, which specifies the destination CIDR block for the route, and a "gateway_id" argument, which specifies the ID of the internet gateway to use for the route. In this case, it retrieves the ID of the internet gateway from the "aws_internet_gateway" resource using the "ig.id" attribute. In short the route takes all traffic `0.0.0.0/0` and forwards it to the internet_gateway we defined in `04-InternetGateway.tf` - this is our path to and from the internet.

___
# 06-Subnets.tf
```
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.Name-Tag} public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.Name-Tag} public-subnet-2"
  }
}
```

The code above defines Amazon Web Services (AWS) subnets and the "aws_subnet" blocks specify that they are managed by the AWS provider - this line: `resource "aws_subnet"`. The "public_subnet_1" and "public_subnet_2" blocks are used to give the resources unique names within the configuration.

Each block includes several arguments that are used to configure the subnet. 
- The "vpc_id" argument specifies the ID of the VPC to which the subnet will be associated. 
- The "cidr_block" argument specifies the CIDR block for the subnet, which is specified using the "public_subnet_1_cidr" and "public_subnet_2_cidr" variables, respectively (*note that they are different*). 
- The "availability_zone" argument specifies the availability zone in which the subnet will be created. In this case, it retrieves the list of availability zones from the "aws_availability_zones" data source using the "available.names" attribute and selects the first and second elements of the list, respectively, so each subnet will reside in **different availability zones**. 
- The "map_public_ip_on_launch" argument is set to "true", which means that instances launched in the subnet will be assigned a public IP address by default, **giving an ec2 instance a public ip address can only be done when first launching the instance**, if you forget then the instance will have to be deleted and a new instance provisioned.

In short the code block above will create two subnets in different available availability zones with different cidr_blocks, all resources will be contained within our created VPC and instances launched within **both** subnets will be allocated public ip addresses on launch. We would call these subnets "public subnets".

___
# 07-RouteTableAssociation.tf
```
resource "aws_route_table_association" "rt_ass_public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt_ass_public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.rt.id
}
```

In code above creates Amazon Web Services (AWS) route table associations and the "aws_route_table_association" blocks specify that they are managed by the AWS provider. The "rt_ass_public_subnet_1" and "rt_ass_public_subnet_2" blocks are used to give the resources unique names within the configuration.

Each block includes two arguments that are used to configure the route table association. 
- The "subnet_id" argument specifies the ID of the subnet to be associated with the route table. In this case, it retrieves the IDs of the "public_subnet_1" and "public_subnet_2" resources using the "public_subnet_1.id" and "public_subnet_2.id" attributes, respectively. 
- The "route_table_id" argument specifies the ID of the route table to be associated with the subnet. In this case, it retrieves the ID of the "rt" route table resource using the "rt.id" attribute.

These resource blocks create associations between the specified subnets and route table, which means that the subnets will use the routes in the route table to determine how to route traffic. This allows traffic to be directed to the internet gateway, which enables instances in the subnets to communicate with the internet (because remember, we added the `0.0.0.0/0` route to the route table in `05-RouteTable.tf` which directs all traffic through the internet gateway)

___
# 08-SecurityGroupWeb.tf
```
resource "aws_security_group" "web_sg" {
  name   = "web sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.Name-Tag} web-security-group"
  }
}
```
This resource is an Amazon Web Services (AWS) security group and the "aws_security_group" block specifies that it is managed by the AWS provider. The "web_sg" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the security group. 
- The "name" argument specifies the name of the security group, and the "vpc_id" argument specifies the ID of the VPC to which the security group belongs. In this case, it retrieves the ID of the VPC from the "aws_vpc" resource using the "vpc.id" attribute.
- The "ingress" blocks specify inbound rules for the security group. Each block includes "from_port" and "to_port" arguments, which specify the range of port numbers to which the rule applies, and a "protocol" argument, which specifies the protocol (e.g. TCP, UDP) to which the rule applies. The "cidr_blocks" argument specifies the CIDR blocks from which traffic is allowed. In this case, the rule allows traffic on ports 80 (http), 443 (https), and 22 (ssh) from any source (0.0.0.0/0)
- The "egress" block specifies an outbound rule for the security group. It allows all outbound traffic 
  - `from_port = 0` means from **all ports** 
  - `to_port = 0` means to **all ports**
  - `protocol = "-1"` means **all protocols** 
  - `cidr_blocks = [0.0.0.0/0]` means to **any/all** destinations
    - In short the `egress` block allows ***everything*** out.

We could apply this security group to any resource that accepts a security group assuming the resource resides within the specified vpc `aws_vpc.vpc.id`.

We could lock-down this security group to specific ip addresses for ssh - this would offer more granular security but falls outside of this tutorials scope.

___
# 09-LaunchConfiguration.tf
```
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
```
This code defines an AWS resource for creating a launch configuration for an EC2 instance. The launch configuration specifies the parameters for launching an Amazon Elastic Compute Cloud (EC2) instance, such as the ID of the Amazon Machine Image (AMI), the instance type, and the key pair to use.

- The name attribute specifies the name of the launch configuration, which is a combination of a fixed string and a variable called Name-Tag.
- image_id attribute specifies the ID of the AMI to use for the instance, and the instance_type attribute specifies the type of instance to launch. 
- key_name attribute specifies the name of the key pair to use, and the user_data attribute specifies data to be used by cloud-init to configure the instance (allows us to ssh into the instance using this particular ssh key). 
- user_data block defines a script that updates the instance, installs, enables and starts nginx on the instances.
- security_groups attribute specifies the security groups to associate with the instance(s)
- lifecycle block specifies that the instance(s) should be created before it/they are destroyed.

___
# 10-AutoScalingGroup.tf
```
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
```

The resource code above is an Amazon Web Services (AWS) Auto Scaling Group (ASG) and the "aws_autoscaling_group" block specifies that it is managed by the AWS provider. The "asg" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the ASG. 
- The "name" argument specifies the name of the ASG. 
- The "min_size" and "max_size" arguments specify the minimum and maximum number of instances that the ASG should maintain. 
- The "desired_capacity" argument specifies the number of instances that the ASG should maintain when it is launched. 
- The "health_check_grace_period" argument specifies the length of time (in seconds) that the ASG should wait before checking the health of an instance after it is launched. 
- The "health_check_type" argument specifies the type of health check to be used to determine the health of the instances. In this case, it uses the EC2 health check.

- The "launch_configuration" argument specifies the launch configuration to be used when launching instances for the ASG. In this case, it retrieves the ID of the "lc" launch configuration using the "lc.id" attribute. 
- The "vpc_zone_identifier" argument specifies the IDs of the subnets in which the instances should be launched. In this case, it retrieves the IDs of the "public_subnet_1" and "public_subnet_2" subnets using the "public_subnet_1.id" and "public_subnet_2.id" attributes, respectively.

- The "tag" block specifies metadata for the ASG in the form of a key-value pair. 
- The "propagate_at_launch" argument specifies that the tag should be applied to the instances launched by the ASG. 
- The "target_group_arns" argument specifies the ARN of the Application Load Balancer (ALB) target group to which the instances should be registered. In this case, it retrieves the ARN of the "target_group" target group using the "target_group.arn" attribute.

This resource block declares an ASG that maintains a certain number of instances within specified limits, uses the specified launch configuration to launch the instances, and launches the instances in the specified subnets. It also specifies a health check to be used to determine the health of the instances, and it registers the instances with the specified ALB target group. It also adds a "Name" tag to the ASG and the instances launched by the ASG for identification purposes.

___
# 11-ApplicationLoadBalancer.tf
```
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    "Name" = "${var.Name-Tag} Application LB"
  }
}
```

The resource above is an Amazon Web Services (AWS) Application Load Balancer (ALB) and the "aws_lb" block specifies that it is managed by the AWS provider. The "alb" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the ALB. 
- The "name" argument specifies the name of the ALB. The "internal" argument specifies whether the ALB should be internal or public. In this case, it is set to "false" to make the ALB public. 
- The "load_balancer_type" argument specifies the type of load balancer. In this case, it is set to "application" to create an ALB (application load balancer). 
- The "security_groups" argument specifies the security groups to be associated with the ALB. In this case, it retrieves the ID of the "web_sg" security group using the "web_sg.id" attribute. 
- The "subnets" argument specifies the IDs of the subnets in which the ALB should be launched. In this case, it retrieves the IDs of the "public_subnet_1" and "public_subnet_2" subnets using the "public_subnet_1.id" and "public_subnet_2.id" attributes, respectively.

___
# 12-TargetGroup.tf
```
resource "aws_alb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    "Name" = "${var.Name-Tag}"
  }
}
```

The resource above is an Amazon Web Services (AWS) Application Load Balancer (ALB) target group and the "aws_alb_target_group" block specifies that it is managed by the AWS provider. The "target_group" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the target group. 
- The "name" argument specifies the name of the target group. 
- The "port" argument specifies the port on which the target group listens for connections. 
- The "protocol" argument specifies the protocol to use when routing traffic to the targets. In this case, it is set to "HTTP" to route HTTP traffic to the targets. 
- The "vpc_id" argument specifies the ID of the VPC in which the target group is created. In this case, it retrieves the ID of the "vpc" VPC using the "vpc.id" attribute.
- The "health_check" block specifies the health check settings for the target group. 
- The "path" argument specifies the ping target for the health check. 
- The "interval" argument specifies the amount of time, in seconds, between health checks. 
- The "timeout" argument specifies the amount of time, in seconds, that the target group waits when trying to establish a connection to the health check target. 
- The "healthy_threshold" and "unhealthy_threshold" arguments specify the number of consecutive failures required before marking a target as unhealthy or the number of consecutive successes required before marking a target as healthy, respectively.

This resource block declares an ALB target group and specifies the port, protocol, and VPC in which it is created. It also specifies the health check settings for the target group and adds a "Name" tag for identification purposes. The target group is used to route traffic to registered targets such as EC2 instances.

___
# 13-AlbListener.tf
```
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }

  tags = {
    "Name" = "${var.Name-Tag} alb listener port 80"
  }
}
```
The resource code above is an Amazon Web Services (AWS) Application Load Balancer (ALB) listener and the "aws_alb_listener" block specifies that it is managed by the AWS provider. The "listener_http" block is used to give the resource a unique name within the configuration.

The block includes several arguments that are used to configure the listener. 
- The "load_balancer_arn" argument specifies the Amazon Resource Name (ARN) of the load balancer to which the listener is attached. In this case, it retrieves the ARN of the "alb" load balancer using the "alb.arn" attribute. 
- The "port" argument specifies the port on which the listener listens for connections. 
- The "protocol" argument specifies the protocol to use when routing traffic to the targets. In this case, it is set to "HTTP" to route HTTP traffic to the targets.
- The "default_action" block specifies the default action to take when a request is received by the listener. 
- The "target_group_arn" argument specifies the ARN of the target group to which to route traffic. In this case, it retrieves the ARN of the "target_group" target group using the "target_group.arn" attribute. 
- The "type" argument specifies the type of routing action to take. In this case, it is set to "forward" to forward traffic to the specified target group.

This resource block declares an ALB listener that listens for HTTP traffic on port 80 and forwards it to the specified target group. It also adds a "Name" tag for identification purposes.


___
# 14-Outputs.tf
```
data "aws_lb" "alb" {
  name = "alb"
  depends_on = [
    aws_lb.alb
  ]
}

output "alb_public_ip" {
  value = data.aws_lb.alb.dns_name
}
```
This code is defining an output variable called "alb_public_ip" that retrieves the public IP address of an Application Load Balancer (ALB) in Amazon Web Services (AWS).

The output variable is defined in two blocks:

- The data "aws_lb" "alb" block retrieves the attributes of an ALB with the name "alb" in the AWS account. The depends_on argument specifies that the data source depends on the aws_lb.alb resource, which means that the data source will be created only after the aws_lb.alb resource has been created.

- The output "alb_public_ip" block defines an output variable called "alb_public_ip" and sets its value to the dns_name attribute of the data.aws_lb.alb data source. The dns_name attribute returns the public DNS name of the ALB, which can be used to access the ALB using a web browser or other client.

When you run the terraform apply command to apply your Terraform configuration, the output variable will be displayed in the terminal along with the public IP address of the ALB. You can then use this IP address to access the ALB from a web browser or other client.

For example, you might see output similar to this:
```
Outputs:

alb_public_ip = alb-12345678.us-west-2.elb.amazonaws.com

```

___
# Summary of Terraform code

We have written the terraform code to provision the following resources on AWS:

1. Virtual Private Cloud (VPC) with a specified CIDR block
2. Internet Gateway (IG) and a Route Table (RT) that allows all outbound traffic
3. Two public subnets in the VPC, each with a specified CIDR block and in different availability zones
4. Two Route Table Association (RTA) resources that associate the RT with the public subnets
5. A Security Group (SG) that allows incoming traffic on ports 80, 443, and 22 and allows all outbound traffic
6. An Autoscaling Group (ASG) that launches EC2 instances from a specified Amazon Machine Image (AMI) and places them in the specified public subnets. Each instance will run the userdata script to install nginx
7. A public Application Load Balancer (ALB) that listens for HTTP traffic on port 80 and routes it to the specified public subnets
8. A Target Group (TG) that registers the EC2 instances launched by the ASG and routes traffic to them
9. An Application Load Balancer Listener (ALB Listener) that listens for HTTP traffic on port 80 and forwards it to the Target Group (TG)
10. We've setup an output that prints the public ip address for our ALB when it's been provisioned, we can copy this address into a web browser and it will forward you to our load balanced application running nginx!

This configuration can be used to set up a simple, load-balanced web server infrastructure in AWS that is highly available, fault tolerant and self healing.

User traffic will be directed in a round-robin way to one of the instances, if we loose an instance or availability zone the autoscaling groups health check will fail and then proceed to provision the desired number of running ec2 instances we have detailed in the `10-AutoScalingGroup.tf` file (`desired = 2`). The load balancer will only forward traffic to healthy instances so there will be little to no disruption to our delivery of the website to our users and they won't notice if one ec2 instance fails. 

___
# Implement the terraform code
1. Open a terminal and navigate to the directory where all the above files are saved.
2. Enter the following commands
```
terraform fmt
```
```
terraform validate
```
- check for any errors
```
terraform plan -out=planout
```
- manually review the plan and see what resources will e created
```
terraform apply planout
```
- the resources will be provisioned.
___
# Conclusion

1. User navigates to the load balancer url and is forwarded to a healthy instance
2. If we were to lose an availability zone or ec2 instance then users would still be forwarded to the remaining healthy instance
3. The Auto Scaling Group health check would fail and a new ec2 instance would be provisioned in the available availability zone
4. Once the new ec2 instance has been provisioned and heathcheck is good the load balancer will start to forward traffic to both instances.

I hope you enjoyed and learned something from this tutorial, if so please feel free to share the article with your friends and peers. If you have any questions then you can catch me on [twitter @DarrenK_dev](https://twitter.com/DarrenK_dev). 

Thanks for reading and I hope to see you again 👋