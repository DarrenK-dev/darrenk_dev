data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "This is the cidr_block for our VPC we will provision."
}

variable "public_subnet_1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "This is the cidr_block for the first public subnet we will provision"
}

variable "public_subnet_2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "This is the cidr_block for the second public subnet we will provision"
}

variable "ami" {
  type        = string
  default     = "ami-084e8c05825742534"
  description = "Ami for Amazon Linux 2 ec2 instance"
}

variable "key-pair-name" {
  type        = string
  default     = "tutorials"
  description = "The ec2 key-pair name used to ssh into ec2 instances, this must already exist"
}

variable "instance-type" {
  type        = string
  default     = "t2.micro"
  description = "The type of ec2 instance (i.e. it's size) to be used within the launch configuration"
}

variable "Name-Tag" {
  type        = string
  default     = "darrenk.dev tutorial"
  description = "The Tag with the key of `Name` value. This will hepl identify resources provisioned from this IaC terraform tutorial viewed through the AWS management console."
}