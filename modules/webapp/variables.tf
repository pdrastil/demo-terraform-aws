variable "vpc" {
  description = "VPC to use for image build"
}

variable "public_subnets" {
  type        = list
  description = "Public subnets on VPC"
}

variable "private_subnets" {
  type        = list
  description = "Private subnets on VPC"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for AMI image"
}

variable "public_key_path" {
  type        = string
  description = "Path to public SSH key for EC2 instances"
}

variable "app_version" {
  type        = string
  default     = "1.0"
  description = "Version of deployed application"
}

variable "app_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for deployed application"
}

variable "elb_timeout" {
  type        = number
  default     = 3
  description = "The timeout for the EC2 health check"
}

variable "elb_interval" {
  type        = number
  default     = 30
  description = "The interval between EC2 health checks"
}

variable "elb_healthy_threshold" {
  type        = number
  default     = 2
  description = "The number of checks before EC2 is declared healthy"
}

variable "elb_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "The number of checks before EC2 is declared unhealthy"
}

variable "asg_min" {
  type        = number
  default     = 1
  description = "The minimum number of running EC2 instances"
}

variable "asg_max" {
  type        = number
  default     = 2
  description = "The maximum number of running EC2 instances"
}

variable "asg_grace" {
  type    = number
  default = 300
}

variable "asg_hct" {
  type        = string
  default     = "EC2"
  description = "Type of health check for autoscaling group"
}

variable "asg_cap" {
  type    = number
  default = 2
}
