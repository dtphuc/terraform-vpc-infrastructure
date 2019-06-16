terraform {
    backend "s3" {
        bucket         = "awslabs-tfstate-123"
        key            = "environment/prod_dcore.tfstate"
        region         = "ap-southeast-1"
        encrypt        = "true"
        dynamodb_table = "terraform-locking"
    }
}

data "terraform_remote_state" "prod_vpc" {
  backend = "s3"
  config {
    bucket         = "awslabs-tfstate-123"
    key            = "infrastructure/env_prod_dcore.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
    dynamodb_table = "terraform-locking"
  }
}