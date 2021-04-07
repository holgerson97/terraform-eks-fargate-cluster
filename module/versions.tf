terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.33.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "tls" {}