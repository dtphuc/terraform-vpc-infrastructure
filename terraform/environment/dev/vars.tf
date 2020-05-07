variable "aws_region" {
  description = "Which region do you want to create?"
}

variable "aws_environment" {
  description = "Which environment?"
  default = "dev"
}

variable "bastion_ami_id" {
  description = "AMI of Bastion Host"
  default     = "ami-0ec3cce62a6b4fc09"
}

variable "aws_vpc_name" {
  default = "devops-practice"
}

variable "aws_image_id" {
  description = "AWS AMI to be used for Node"
  default     = "ami-0bc6a2a5613de8f18"
}

variable "aws_key_name" {
  description = "AWS Keypair name"
  default     = "devops-keypair"
}

variable "aws_instance_type" {
  default  = "t2.micro"
}

variable "aws_profile_name" {
  default = "ec2_profile"
}

variable "aws_role_name" {
  default = "ec2_role"
}

variable "termination_policies" {
  description = "Policies to terminate your instance in ASG. Values: Default, OldestLaunchConfiguration, OldestInstance, ClosestToNextInstanceHour, NewestInstance"
  type = list
  default = ["OldestLaunchConfiguration","OldestInstance","ClosestToNextInstanceHour","Default"]
}

variable "aws_role" {
  description = "Describe about your stack/role of your application. For example: Nodes"
  default     = "Nodes"
}

variable "target_group_port" {
  description = "Port to open so that ALB can route traffic to"
  default     = "80"
}

variable "target_group_protocol" {
  description = "Protocol to run your application"
  default     = "HTTP"
}

variable "internal" {
  description = "Scheme for your ALB. Internal can be accessed within VPC. Internal-Facing can be accessed via VPN or Internet. Values: false or true"
  default     = "false"
}


variable "target_healthcheck" {
  description = "Describe path so that ALB can run healthcheck"
  default     = "/"
}

variable "condition_field" {
  description = "The kind of ALB type: path-pattern or host-header. Values: path-pattern or host-header"
  default     = "path-pattern"
}

variable "condition_values" {
  type     = list
  default  = ["/"]
}

variable "enable_stickiness" {
  default = "true"
}

variable "min_size" {
  description = "Min instances of ASG"
  default     = "2"
}

variable "max_size" {
  description = "Max instances of ASG"
  default     = "2"  
}

variable "desired_size" {
  description = "Desired instances of ASG"
  default     = "2"
}

variable "wait_for_elb_capacity" {
  description = "wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations"
  default     = "1"
}
variable "health_check_grace_period" {
  description = "Time after instance comes into service before checking health."
  default     = 600
}

variable "health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done."
  default     = "ELB"
}
variable "default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity."
  default     = 300
}
variable "protect_from_scale_in" {
  description = "The autoscaling group will not select instances with this setting for terminination during scale in events."
  default     = false
}


variable "aws_scale_out" {
  description = "The number of instance will be scaled out"
  default     = "1"
}
variable "aws_scale_in" {
  description = "The number of instance will be scaled in"
  default     = "-1"
}

variable "http_listener_count" {
  description = "Number of HTTP Listener"
  default     = "1"
}

# Resource for ALB
variable "http_listener_port" {
  description = "HTTP Port Listener"
  type        = list
  default     = ["80"]
}

variable "http_listener_rule_count" {
  description = "Number of HTTP Listener Rule"
  default     = "1"
}

# For ASG
variable "tagName" {
  description = "Your ASG Name to be applied as tag"
  default     = "dev-asg"
}

variable "tagEnvironment" {
  description = "Tagging Environment for your ASG"
  default     = "dev"
}

variable "tagRole" {
  description = "Tagging Role for your ASG"
  default     = "Nodes"
}

variable "tagApplication" {
  description = "Tagging Application for your ASG"
  default     = "AppNode"
}

variable "tagSupportGroup" {
  description = "Tagging Support Group for your ASG"
  default     = "Platform"
}

variable "tagOSVersion" {
  description = "Tagging OS Version for your ASG"
  default     = "CentOS-7"
}

variable "tagBuilder" {
  description = "Tagging Builder for your ASG"
  default     = "Terraform"
}

variable "custom_security_group" {
  description = "IP Address can be allowed to access ALB"
  default = "1.53.197.158/32"
}
