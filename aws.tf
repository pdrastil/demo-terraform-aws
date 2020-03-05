terraform {
  required_version = "0.12.21"
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source      = "./modules/network"
  environment = var.environment
  cidr_block  = var.network_cidr
}
