variable "aws_region" {
  default = "ap-southeast-1"
}

variable "aws_environment" {
  default = "prod"
}

variable "aws_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "aws_vpc_name" {
  default = "prod-Dcore"
}
variable "aws_availability_zones" {
  type    = "list"
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidr_all" {
  type    = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_all" {
  type    = "list"
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

