terraform {
    backend "s3" {
        bucket         = "awslabs-tfstate-123"
        key            = "infrastructure/env_dev_dcore.tfstate"
        region         = "ap-southeast-1"
        encrypt        = "true"
        dynamodb_table = "terraform-locking"
    }
}