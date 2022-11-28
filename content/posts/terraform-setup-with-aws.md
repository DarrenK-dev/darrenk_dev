---
title: "Terraform Setup with AWS IAM User (MacOS)"
date: 2022-11-26T16:43:16Z
draft: true
---

=======> PICTURE HERE

___
___
#### Prerequisites

- AWS account
- `aws-cli (v2)` installed on your local machine
- `terraform` installed to your local machine
___























___





























## Tutorial steps:

1. [Create an AWS IAM User](#create-an-aws-iam-user) called 'terraform-cli-user', and attached permissions.
2. [Save AWS User credentials to aws-cli](#save-aws-user-credentials-to-aws-cli).
3. [Ensure Terraform is installed](#check-terraform-is-installed) on our local machine.
4. [Configure Terraform](#configure-terraform-with-aws-user) with our AWS User credentials stored on our local machine.
5. Provision some basic infrastructure to AWS using Terraform and IaC.

If you're more experienced and have the aws cli installed and configured then I've written a section detailing cli commands only (without the other content), feel free to jump straight to that section.
- [AWS CLI commands only]()
___
### Tools used in this tutorial

- Homebrew - [*installation docs*](https://docs.brew.sh/Installation)
- AWS CLI (version2) - [*installation docs*](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform - [*installation docs*](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS](https://aws.amazon.com/) account (with relevant permissions)
___
## Create an AWS IAM User

- Log into the AWS console
- Search for "IAM" in the search bar and click IAM
- Click on 'Users'
- Click on 'Add users'
- Enter a user name, we'll call the user "terraform-cli-user"
- Under "Select AWS credential type" select "Access key - Programmatic access"

![Add User](/add-user.png)
- Click ***"Next: Permissions"***
- Click the ***"Attach existing policies directly"***
- Search for ***"AdministratorAccess"***
- Select the checkbox against the policy   
> NOTE:   
🚨 We should **ALWAYS** follow "**The principle of least privilege**" (POLP) when in a production environment. *We are conducting this tutorial for educational purposes ONLY! - these persissions are not suitable for a production environment!*   
Why?   
IAM policies, roles and groups are outside the scope of this tutorial. In production you should **NEVER** grant full access to ANY user if not necessary to perform their role - if the user account gets compromised it can be dangerous, lead to data breaches, deletion of infrastructure, malicious redirects the list goes on... Only give the needed permissions for a user to carryout their role (e.g. if a user only needs to read from S3 buckets then don't give them write or delete permissions, let-alone full access to RDS Databases).   


![Administrator Access Policy Screenshot](/admin-access-policy.png)

- Click ***"Next: Tags"***
- Add the following tag: Managed-By : Terraform

![Administrator Access Policy Screenshot](/managed-by-terraform-tag.png)

- Click ***"Next: Review"***

![Administrator Access Policy Screenshot](/terraform-setup-with-aws/create-user.png)

- Finally click ***"Create user"***

You'll now be taken to a splash screen where your user has been created, you'll have the option to download the csv key-pair information.

- **🚨 DOWNLOAD THE CSV FILE AND STORE IT SAFELY - IT CAN NOT BE RECOVERED**   
- **🚨 DO NOT SHARE THESE CREDENTIALS WITH ANYONE**   

![Administrator Access Policy Screenshot](/terraform-setup-with-aws/download-csv-key.png)

___
## Save AWS User credentials to aws-cli

In this part of the tutorial we'll be using the aws-cli package to save the user credentials to our local machine.

- Open a terminal and enter the following command:
```
aws configure --profile terraform-cli-user
```
Use the credentials downloaded as a csv file in the previous step...
- `AWS Access Key ID [None]: <ENTER-YOUR-CREDENTIALS-HERE>`
- `AWS Secret Access Key [None]: <ENTER-YOUR-CREDENTIALS-HERE>`
- `Default region name [None]: us-east-1`
- `Default output format [None]: json`

We can check if the user credentials have been saved by entering the following command into terminal:


```
cat ~/.aws/credentials
```
You should see an output similar to:
```
[terraform-cli-user]
aws_access_key_id = <your-key-will-show-here>   
aws_secret_access_key = <your-secret-will-show-here>
```

___
## Check Terraform is installed

If you think Terraform is installed on your local machine then enter the following command into a terminal window.
```
terraform --version
```

...it should output something like `Terraform v1.3.2` - if so then you're ready for the next step.

*The installation of Terraform is beyond the scope of this tutorial, I'm going to write a tutorial soon but in the meantime take a look at [HashiCorps official documentation](#) for instructions on how to install Terraform.*

___
## Configure Terraform with AWS User


1. Create our tutorial folder called `terraform_aws_tutorial`   
You can create this where you want but I'll be creating this folder in my local machines user root director.
```
mkdir ~/terraform_aws_tutorial
```

2. Create a Terraform file inside of the folder
```
touch ~/terraform_aws_tutorial/main.tf
```

3. Open the folder with your preferred IDE, I'm using VSCode.
```
code ~/terraform_aws_tutorial
```

4. Copy the following code block into main.tf
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "terraform-cli-user"
  region  = "us-east-1"
  alias   = "tf-user"
}

resource "aws_vpc" "tutorial_vpc" {
  provider             = aws.tf-user
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "darrenk.dev-tutorial`"
  }
}
```

5. Enter the following commands in terminal
```
cd ~/terraform_aws_tutorial
```
```
terraform init
```


