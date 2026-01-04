terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }


  backend "s3" {
    bucket         = "my-project-s3-2026"
    key            = "fastapi_app/dev/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "my-project-dynamodb-2026"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}