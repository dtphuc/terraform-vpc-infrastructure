data "aws_availability_zones" "available" {}

variable "public_subnet_id" {}

variable "aws_environment" {
    description = "Define environment"
}

variable "bastion_ami_id" {}

variable "aws_key_name" {
}

variable "aws_description" {
  default = "Managed by Terraform. DO NOT change it manually."
}

variable "aws_bastion_sgr_name" {
}

variable "aws_bastion_instance_name" {
}

variable "aws_instance_type" {
}

variable "vpc_cidr_block" {
  description = "CIDR for subnet in VPC"
}

variable "custom_security_rules" {}

/*
# Retrieves state meta data from a remote backend
*/
data "terraform_remote_state" "dev_vpc" {
  backend = "s3"
  config = {
    bucket         = "dev-ap-southeast-1-devops-tfstate"
    key            = "dev/dev_vpc.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
  }
}
