variable "app_version" {
  type        = string
  default     = "1.0"
  description = "Version of deployed application"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for AMI image"
}

variable "vpc_id" {
  type        = string
  description = "VPC to use for image build"
}
