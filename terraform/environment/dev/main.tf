provider "aws" {
  	region     = var.aws_region
  	version = "~> 2.7"
}

data "template_file" "configure_app" {
  	template = file("${path.module}/../../templates/userdata.sh.tpl")
}

resource "aws_key_pair" "keypair" {
	key_name   = var.aws_key_name
	public_key = file("${path.module}/../../keys/dev_keypair.pub")
}

module "bastion" {
	source                    = "../../modules/bastion/"
	vpc_cidr_block            = data.terraform_remote_state.dev_vpc.outputs.vpc_cidr_block
	public_subnet_id          = data.terraform_remote_state.dev_vpc.outputs.public_subnet_ids[0]
	bastion_ami_id            = var.bastion_ami_id
	aws_key_name              = aws_key_pair.keypair.key_name
	aws_environment           = var.aws_environment
	aws_bastion_sgr_name      = "bastion"
	aws_bastion_instance_name = "Dev-BastionHost"
	aws_instance_type         = var.aws_instance_type
	custom_security_rules     = var.custom_security_group
}

module "alb" {
	source                       = "../../modules/alb/"
	aws_region                   = var.aws_region
	vpc_id                       = data.terraform_remote_state.dev_vpc.outputs.vpc_id
	vpc_cidr_block               = data.terraform_remote_state.dev_vpc.outputs.vpc_cidr_block
	vpc_name                     = "${var.aws_environment}-${var.aws_vpc_name}"
	public_subnet_ids            = data.terraform_remote_state.dev_vpc.outputs.public_subnet_ids[0]
	aws_environment              = var.aws_environment
	aws_role                     = var.aws_role
	target_group_port            = var.target_group_port
  	target_group_protocol        = var.target_group_protocol
  	internal                     = var.internal
  	target_healthcheck           = var.target_healthcheck
  	condition_field              = var.condition_field
  	condition_values             = var.condition_values
  	enable_stickiness            = var.enable_stickiness
	http_listener_rule_count     = var.http_listener_rule_count

  	http_listener_count          = var.http_listener_count
  	http_listener_port           = var.http_listener_port
}


module "asg" {
	source                   = "../../modules/asg/"
	aws_environment          = var.aws_environment
	aws_image_id             = var.aws_image_id
	aws_key_name             = aws_key_pair.keypair.key_name
	aws_security_group_id    = [aws_security_group.this.id]
	vpc_zone_identifier       = data.terraform_remote_state.dev_vpc.outputs.private_subnet_ids[0]
	associate_public_ip_address = true
	aws_instance_type        = var.aws_instance_type
	iam_instance_profile     = ""
	aws_userdata             = data.template_file.configure_app.rendered
	min_size                 = var.min_size
	max_size                 = var.max_size
	desired_size             = var.desired_size
	wait_for_elb_capacity    = var.wait_for_elb_capacity
	aws_scale_out            = var.aws_scale_out
	aws_scale_in             = var.aws_scale_in
	health_check_grace_period= var.health_check_grace_period
	health_check_type        = var.health_check_type
	default_cooldown         = var.default_cooldown
	protect_from_scale_in    = var.protect_from_scale_in
	termination_policies     = var.termination_policies
	tagName                  = var.tagName
	tagEnvironment           = var.tagEnvironment
	tagRole                  = var.tagRole
	tagApplication           = var.tagApplication
	tagSupportGroup          = var.tagSupportGroup
	tagOSVersion             = var.tagOSVersion
	aws_lb_target_group      = [module.alb.target_group_arn]
}

