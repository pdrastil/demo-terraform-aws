# Terraform demo for AWS

This repository contains sample deployment of infrastructure to
AWS with Terraform and Packer.

## Goal

Project goal is to create highly available infrastructure in AWS that is using classic EC2 instances as a servers for web application.

### What gets deployed

- AWS VPC with default CIDR 10.0.0.0/16
- Public and private subnets in 2 availability zones
- AMI image with web application
- Elastic load balancer for public subnets
- Autoscaling group with web application in private zone
- Security groups to allow public access only to load balancer

### Gotchas

Demo implementation is not entirely immutable. This is caused by integration of Packer into terraform scripts via `null_resource` provider. When you do this AMI search gets dependent on Packer and will be invalidated for any consequent run of terraform which causes replacement of every resource that consumes such AMI. This behavior was kept for sake of simplicity and to allow you do the teardown of whole environment without leaving anything behind.

If you would like to modify this for production it's recommended to have special network where your automation tooling lives and where you can perform AMI build independently before invoking terraform. Then you will just trigger another job with desired image ID that should be used by terraform.

## Setup

Please refer to next sections what should be installed and configured to make this demo work.

### Software

- [Ansible] via `pip install ansible`
- [AWS CLI] via `pip install awscli`
- [Terraform]
- [Packer]

### Amazon Web Services

To test the deployment you will need to have AWS account. In the account activate subscription for [CentOS 7] image that is used as base image for Packer build. Also create user account with Administrator privileges and programatic access. Then run `aws configure` and enter your access key and secret key for this user account.

If you already use AWS and have account with Administrator privileges, then this demo expects that such account is a default one. If you need to assume role or have such account in different profile it's recommended to use tool such as [aws-vault] to inject
your environment with valid credentials prior the deployment.

### Private keys for EC2 instances

To create EC2 instances you need create SSH key pair used for authentication. Run `ssh-keygen` to generate new key pair and create override in `terraform.tfvars` or modify default value in [variables.tf](./variables.tf) to provide valid
path to your public key.

## Usage

To deploy AWS environment with Terraform run following:

```sh
$ terraform init
$ terraform plan
$ terraform apply
```

[Ansible]: <https://ansible.com/>
[AWS CLI]: <https://aws.amazon.com/cli/>
[Packer]: <https://packer.io/>
[Terraform]: <https://terraform.io/>
[CentOS 7]: <https://aws.amazon.com/marketplace/pp/B00O7WM7QW/>
[aws-vault]: <https://github.com/99designs/aws-vault>
