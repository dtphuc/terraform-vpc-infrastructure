data "aws_availability_zones" "available" {}
variable "aws_region" {}
variable "aws_environment" {}
variable "aws_role" {}
variable "custom_security_group" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "vpc_name" {}

variable "vpc_id" {}
variable "vpc_cidr_block" {}

variable "target_group_port" {}
variable "target_group_protocol" {}

variable "ssl_listener_certificate_arn" {}
variable "internal" {
  description = "ALB for Internal Use or Internet facing"
}
variable "target_healthcheck" {}
variable "condition_field" {}
variable "condition_values" {
  type = "list"
}
variable "enable_stickiness" {}
variable "http_listener_count" {}
variable "http_listener_port" {
  type = "list"
}
variable "http_listener_rule_count" {}

variable "https_listener_count" {}
variable "https_listener_port" {
  type = "list"
}
variable "https_listener_rule_count" {}

variable "aws_description" {
  default = "Managed By Terraform. DO NOT Change it manually.!!"
}
