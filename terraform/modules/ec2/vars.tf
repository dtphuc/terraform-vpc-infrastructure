data "aws_availability_zones" "available" {
}

variable "aws_instance_count" {
  description = "How many EC2 instances do you want to create?"
}

variable "aws_environment" {
  description = "Which environment does this EC2 belong ?"
}

variable "aws_description" {
  default = "Managed by Terraform. DO NOT change it manually."
}

variable "subnet_id" {
  description = "Which Subnet ID does EC2 belong?"
}

variable "ami_id" {
  description = "What is AMI ID for this EC2 instance to be used?"
}

variable "aws_instance_type" {
  description = "What is the EC2 instance type you want to run?"
}

variable "user_data" {
  description = "What is your userdata you want to run as bootstrap ?"
}

variable "aws_key_name" {
  description = "What is your SSH Key name?"
}

variable "vpc_security_group_ids" {
  description = "What is the security group for this EC2?"
}

variable "iam_instance_profile" {
  description = "What is the EC2 instance profile you want to attach ?"
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "instance_name" {
  description = "What is your EC2 instance name?"
}

variable "instance_class" {
  description = "What class does your EC2 instance belong?"
}

variable "root_volume_size" {
  description = "Root Volume Size"
  default = 50
}

variable "root_volume_type" {
  description = "Root Volume Type"
  default = "gp2"
}

variable "encrypted" {
  description = "Enable volume encryption"
  default = "false"
}

