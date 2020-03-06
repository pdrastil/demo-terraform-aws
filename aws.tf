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

module "webapp" {
  source          = "./modules/webapp"
  app_version     = var.app_version
  public_key_path = var.public_key_path
  vpc             = module.network.vpc
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets

}
