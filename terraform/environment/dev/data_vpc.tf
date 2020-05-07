data "terraform_remote_state" "dev_vpc" {
  backend = "s3"
  config = {
    bucket         = "dev-ap-southeast-1-devops-tfstate"
    key            = "dev/dev_vpc.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
  }
}
