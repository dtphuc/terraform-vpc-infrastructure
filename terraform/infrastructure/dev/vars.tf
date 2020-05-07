variable "aws_region" {
  default = "ap-southeast-1"
}

variable "create_vpc" {
  default = true
}

variable "aws_environment" {
  default = "dev"
}

variable "aws_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "aws_vpc_name" {
  default = "devops-practice"
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidr_all" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "create_private_subnet" {
  default = true
}

variable "private_subnet_cidr_all" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

