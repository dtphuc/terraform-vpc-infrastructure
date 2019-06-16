variable "aws_region" {
  default = "ap-southeast-1"
}

variable "aws_environment" {
  default = "dev"
}

variable "bastion_ami_id" {
  description = "AMI of Bastion Host"
  default     = "ami-0310794100e4f4d59"
}

variable "aws_vpc_name" {
  default = "Dev-Dcore"
}

variable "aws_image_id" {
  description = "AWS AMI to be used for Dcore Node"
  default     = "ami-09ca247aaaa584bca"
}

variable "aws_key_name" {
  description = "AWS Keypair name"
  default     = "devops-keypair"
}

variable "aws_instance_type" {
  default  = "t2.micro"
}

variable "aws_bucket_name" {
  default = "awslabs-dcore"
}

variable "bucket_acl" {
  default = "private"
}

variable "versioning" {
  default = "true"
}

variable "aws_policy_name" {
  default = "ec2_dcore_policy"
}

variable "aws_profile_name" {
  default = "ec2_dcore_profile"
}

variable "aws_role_name" {
  default = "ec2_dcore_role"
}

variable "aws_cloudwatch_log_name" {
  default = "awslabs-dcore-logs"
}
variable "aws_cloudwatch_logstream_name" {
  default = "awslabs-dcore-logstream"
}

variable "retention_in_days" {
  default = "30"
}

variable "termination_policies" {
  description = "Policies to terminate your instance in ASG. Values: Default, OldestLaunchConfiguration, OldestInstance, ClosestToNextInstanceHour, NewestInstance"
  type = "list"
  default = ["OldestLaunchConfiguration","OldestInstance","ClosestToNextInstanceHour","Default"]
}

variable "aws_role" {
  description = "Describe about your stack/role of your application. For example: Dcore Nodes"
  default     = "Dcore-Nodes"
}

variable "target_group_port" {
  description = "Port to open so that ALB can route traffic to"
  default     = "8090"
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
  type     = "list"
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
  type        = "list"
  default     = ["80"]
}

variable "http_listener_rule_count" {
  description = "Number of HTTP Listener Rule"
  default     = "1"
}

variable "https_listener_count" {
  description = "Numner of HTTPS Listener"
  default     = "0"
}

variable "https_listener_port" {
  description = "HTTP Port Listener"
  type        = "list"
  default     = ["80"]
}

variable "https_listener_rule_count" {
  description = "Number of HTTP Listener Rule"
  default     = "0"
}

variable "https_ssl_arn" {
  default = ""
}

# For ASG
variable "tagName" {
  description = "Your ASG Name to be applied as tag"
  default     = "dev-dcore-asg"
}

variable "tagEnvironment" {
  description = "Tagging Environment for your ASG"
  default     = "dev"
}

variable "tagRole" {
  description = "Tagging Role for your ASG"
  default     = "Dcore-Nodes"
}

variable "tagApplication" {
  description = "Tagging Application for your ASG"
  default     = "Dcore"
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
  description = "List of IP Address can be allowed to access ALB"
  default = ["1.54.5.245/32", "42.114.143.216/32"]
}
