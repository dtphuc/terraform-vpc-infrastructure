variable "aws_availability_zones"  {
    type        = "list"
    description = "Define the AWS AZ you want to deploy your stack"
}

variable "aws_vpc_name" {
    description = "Define the AWS VPC Name"
}

variable "aws_environment" {
  description = "Define environment"
}

variable "aws_vpc_cidr" {
  description = "CIDR for the whole VPC"
}

variable "public_subnet_cidr_all" {
  type    = "list"
}

variable "private_subnet_cidr_all" {
  type    = "list"
}


variable "aws_description" {
  default = "Managed by Terraform. DO NOT change it manually."
}