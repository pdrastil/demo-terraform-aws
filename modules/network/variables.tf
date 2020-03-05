variable "environment" {
  type        = string
  description = "The name of VPC environment"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block for given network"
}
