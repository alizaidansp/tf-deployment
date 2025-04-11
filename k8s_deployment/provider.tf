terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "ali-amalitech-state-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_s3_bucket" "terraform_state" {
  bucket = "ali-amalitech-state-bucket"
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = data.aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = data.aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}