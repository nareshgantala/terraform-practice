terraform {
  backend "s3" {
    bucket = "nareshcloud-terraform-state"
    key    = "qa/terraform.state"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.22.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# VPC-1