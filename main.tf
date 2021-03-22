terraform {
  backend "remote" {
    organization = "e113"

    workspaces {
      name = "e1113-aws-eks-fargate"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.33.0"
    }
  }
}

provider "aws" {
    region     = "eu-central-1"
    access_key = var.AWS_ACCESS_KEY_ID
    secret_key = var.AWS_SECRET_ACCESS_KEY
}

module "eks-fargate" {
    source = "./modules/"
    
}