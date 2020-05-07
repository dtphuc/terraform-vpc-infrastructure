variable "aws_environment" {}

variable "aws_image_id" {}

variable "aws_instance_type" {}

variable "aws_key_name" {}

variable "aws_security_group_id" {}

variable "associate_public_ip_address" {}
variable "iam_instance_profile" {
  description = "This variable will be used as a dependency to be decided to create ASG or not"
}

variable "aws_userdata" {}
variable "vpc_zone_identifier" {}
variable "wait_for_elb_capacity" {
  description = "wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations"
}

variable "min_size" {
  description = "Minimum instance to run"
}

variable "max_size" {
  description = "Maximum instance to run"
}

variable "desired_size" {
  description = "Desired instance to run"
}

variable "health_check_grace_period" {
  description = "Time after instance comes into service before checking health."
}

variable "health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done."
}

variable "default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity."
}

variable "protect_from_scale_in" {
  description = "The autoscaling group will not select instances with this setting for terminination during scale in events."
}

variable "termination_policies" {
  type = list(string)
  description = "The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default"
}

variable "tagName" {
  description = "Your ASG Name to be applied as tag"
}

variable "tagEnvironment" {
  description = "Tagging Environment for your ASG"
}

variable "tagRole" {
  description = "Tagging Role for your ASG"
}

variable "tagApplication" {
  description = "Tagging ApplicationID for your ASG"
}

variable "tagSupportGroup" {
  description = "Tagging Support Group for your ASG"
}

variable "tagOSVersion" {
  description = "Tagging OS Version for your ASG"
}

variable "aws_lb_target_group" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
  type        = list(string)
}

variable "aws_scale_out" {
  description = "The number of instance will be scaled out"
}

variable "aws_scale_in" {
  description = "The number of instance will be scaled in"
}

variable "adjustment_type" {
  default = "ChangeInCapacity"
}

variable "metric_name" {
  default = "CPUUtilization"
}

variable "comparison_operator_greater" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "comparison_operator_less" {
  default = "LessThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  default = "2"
}

variable "namespace" {
  default = "AWS/EC2"
}

variable "period" {
  default = "300"
}

variable "statistic" {
  default = "Average"
}

variable "threshold_in" {
  default = "85"
}

variable "threshold_out" {
  default = "20"
}

variable "aws_description" {
  default = "Managed By Terraform. DO NOT Change it manually.!!"
}

