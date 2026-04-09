terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {
    bucket  = "aws-lab-bucket-aws-lab-diniz"
    key     = "terraform/state/terraform.tfstate"
    region  = "us-east-1"
    profile = "pessoal"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "pessoal"
}