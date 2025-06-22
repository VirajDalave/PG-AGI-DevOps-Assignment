
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.17.0" }
  }

  backend "s3" {
    bucket         = "pgagi-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "pgagi-terraform-locks"  
    encrypt        = true
  }
}

provider "aws" {
  region  = "ap-south-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "pgagi-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a","ap-south-1b"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_dns_hostnames = true
  enable_dns_support = true 
  
  enable_nat_gateway         = true        
  single_nat_gateway         = true       
  
  
}

module "alb" {
  source = "./modules/alb"
  public_subnets = module.vpc.public_subnets
  backend_target_group_arn = module.ecs.backend_target_group_arn
  frontend_target_group_arn = module.ecs.frontend_target_group_arn
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source = "./modules/ecs"
  private_subnets = module.vpc.private_subnets
  image_tag = var.image_tag
  vpc_id = module.vpc.vpc_id
  alb_sg_id = module.alb.alb_sg_id
  frontend_api_url = "http://${module.alb.alb_dns_name}"
}


