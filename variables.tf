variable "app_version" {
  type        = string
  default     = "v1.0"
  description = "Version of deployed application"
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for deployment"
}

variable "environment" {
  type        = string
  default     = "demo"
  description = "The name of the deployment environment"
}

variable "network_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR for deployment environment"
}

variable "public_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "SSH key for accessing EC2 instances"
}
