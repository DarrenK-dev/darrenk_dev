---
title: "IaC - Terraform Loadbalanced Nginx on AWS"
date: 2022-11-23T15:40:34Z
draft: true
---


___
## Prerequisites
In order to follow along with this tutorial you'll need to have a few things setup including an AWS account, a User with programmatic access to aws with the correct policies to create, manage and remove aws resources detailed in this tutorial and aws-cli.

I've written a short tutorial on my Terraform setup [here](#)...
___

### Setting up Terraform
- I'm calling this tutorial "project_1", so let's create a directory in a convenient location. I'll be using terminal for this command...
```
mkdir ~/project_1
```

Open the `~/project_1` folder with your chosen IDE I'm using VS Code as it's free and has lots of nice plugins we can leverage in writing our code.

___

### `backend.tf`

First we need to tell terraform what we're working with, in this tutorial we're deploying our infrastructure on AWS, so let's create a file called `backend.tf` in our main project folder...

```
# ~/project_1

touch backend.tf
```

Now we'll edit the file to include our terraform block...

```
# ~/project_1/backend.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```
This code block will tell Terraform that it need to fetch the AWS provider code so it can interact with AWS to provision, manage and remove resources programmatically. 

___
### `providers.tf`

Next we'll setup or providers, create a new file called `providers.tf` in the project directory root and enter the following code...

```
# ~/project_1/providers.tf

provider "aws" {
  profile = var.profile
  region  = var.london
  alias   = "london"
}
```
...we're only working in `eu-west-2` London region in this tutorial.   
By setting up a provider with an alias `london` we can reference it within our code with `aws.london` - it helps reduce typo errors.

___
### `variables.tf`

As you can see we're referencing some variables within this document using the `var` keyword, this is to show how variables can be used (maybe not the most helpful in this instance, but I wanted to detail them) so let's setup a file to store our variables in, we might even add more variables later...


```
# ~/project_1/variables.tf

variable "profile" {
  type    = string
  default = "default"
}

variable "london" {
  type    = string
  default = "eu-west-2"
}
```
The `"profile"` block will use the aws-cli default account.   
The `"london"` block will have a default value of `eu-west-2`.   
Now our code will work with any variables setup in the `variables.tf` file.

___
### `terraform init`
Once these three files are in place we can initialize Terraform with the following command (make sure you're within the project directory when you execute this command, in my case `~/project_1`).

```
terraform init
```

Terraform will goto work looking through all `.tf` files within our directory and find the `terraform { ... }` code block within the `~/project_1/backend.tf` file. Terraform will then download the required providers, in our project that's AWS. Once complete you'll see a message similar to `Terraform has been successfully initialized!` printed to your terminal. Now we're ready to write some IaC!


___
## Terraform

I'm going to move quite quickly through the IaC section and focus on the code.
___
### Create a VPC

Now we're diving into the IaC. In this section we'll write the terraform code to create our VPC in the eu-west-2 region.   
We're going to place all our "networking" code into a file called `networks.tf`

```
# ~/project_1/networks.tf

resource "aws_vpc" "vpc_project1" {
  provider             = aws.london
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "Project1 VPC"
  }
}
```

___
### Create Subnets

I'm creating two subnets to offer our application some resilience and higher availability.

```
# ~/project_1/networks.tf

# Get all available Availability Zones within our VPC
data "aws_availability_zones" "azs_london" {
  provider = aws.london
  state    = "available"
}

# Create a subnet in london first available availability zone.
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs_london.names, 0)
  vpc_id            = aws_vpc.vpc_project1.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name" = "subnet_1"
  }
}
```

Code summary:   
- `data` block is gathering all available AZs in our London region. We use this data in the subnet creation.
- `aws_subnet` block is creating a subnet in our previously created VPC and within one of Londons available AZs
- `cidr_block` configures the ip range of this subnet