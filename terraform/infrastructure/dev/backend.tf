terraform {
    backend "s3" {
      bucket         = "dev-ap-southeast-1-devops-tfstate"
      key            = "dev/dev_vpc.tfstate"
      region         = "ap-southeast-1"
      encrypt        = "true"
      dynamodb_table = "dev-ap-southeast-1-devops-locking"
    }
}
