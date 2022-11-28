---
title: "Terraform Backend Configuration"
date: 2022-11-26T16:07:11Z
draft: true
---

## What is a Terraform Backend?

According to the official documentation...

> *"A backend defines where Terraform stores its state."*

So I guess you need to know what terraform state is then?

## Terraform State

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

By default this state is stored in a local file named `terraform.tfstate`, but it can also be stored remotely, which works better in a team environment and offers better redundancy and security (it's not so easy to delete the state when stored remotely - say in an S3 bucket).

Terraform uses persisted state data to keep track of the resources it manages. Most non-trivial Terraform configurations either integrate with Terraform Cloud or use a backend to store state remotely. This lets multiple people access the state data and work together on that collection of infrastructure resources.

## Type of Terraform Backends

- local (default)
- remote (preferred for production environments)

By default terraform uses the local backend method. It stores state data in a file called `terraform.tfstate` located in the project root directory (the folder where you executed `terraform init`). This is great for local development and testing environment but I wouldn't recommend a local backend for a production ready application.

So if you want to test terraform out then just use the default local backend - you'll have nothing to setup but you'll sacrefice redundancy.

## Setting up a Terraform Remote Backend

In this tutorial I'll be using AWS S3 Bucket service to store our `terraform.tfstate`file. This will offer 11 9's of data durability and also give some exposure to the aws-cli.

To start we'll create an AWS S3 bucket using the aws-cli tool, I'm presuming you have this setup or you know how to create a new S3 bucket via the AWS Console.

We need to allow the terraform aws user to perform particular tasks on s3 - remember that we setup an aws iam user called terraform user and configured terraform with that iam user credentials.

```
aws s3api create-bucket --bucket terraform-state-bucket --region us-east-1
```