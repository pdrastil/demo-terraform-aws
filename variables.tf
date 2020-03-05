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
