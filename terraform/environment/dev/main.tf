provider "aws" {
  	region     = "${var.aws_region}"
  	version    = "~> 1.0"
}

data "template_file" "configure_app" {
  	template = "${file("${path.module}/../../templates/dcore-userdata.sh.tpl")}"
  	vars {
		mount_dir = "/opt/dcore"
	}
}

resource "aws_key_pair" "keypair" {
	key_name   = "${var.aws_key_name}"
	public_key = "${file("${path.module}/../../keys/dev_keypair.pub")}" 
}

module "bastion" {
	source                    = "../../modules/bastion/"
	vpc_cidr_block            = "${data.terraform_remote_state.dev_vpc.vpc_cidr_block}"
	public_subnet_id          = "${data.terraform_remote_state.dev_vpc.public_subnet_ids[0]}"
	bastion_ami_id            = "${var.bastion_ami_id}"
	aws_key_name              = "${aws_key_pair.keypair.key_name}"
	aws_environment           = "${var.aws_environment}"
	aws_bastion_sgr_name      = "bastion"
	aws_bastion_instance_name = "Dev-BastionHost"
	aws_instance_type         = "${var.aws_instance_type}"
	custom_security_rules     = "${var.custom_security_group}"
}

module "dcore-s3" {
	source          = "../../modules/s3bucket/"
	aws_bucket_name = "${var.aws_bucket_name}"
	aws_region      = "${var.aws_region}"
	aws_environment = "${var.aws_environment}"
	bucket_acl      = "${var.bucket_acl}"
	versioning      = "${var.versioning}"
}

module "dcore-cloudwatch-logs" {
  	source                        = "../../modules/cloudwatch-logs/"
  	aws_cloudwatch_log_name       = "${var.aws_cloudwatch_log_name}"
	aws_cloudwatch_logstream_name = "${var.aws_cloudwatch_logstream_name}"
  	aws_environment               = "${var.aws_environment}"
  	retention_in_days             = "${var.retention_in_days}"           
}

data "template_file" "policy" {
	template = "${file("${path.module}/../../templates/ec2_policy.json")}"
	vars {
		aws_bucket_arn          = "${module.dcore-s3.s3_bucket_arn}"
		aws_cloudwatch_logs_arn = "${module.dcore-cloudwatch-logs.cloudwatch_logs_arn}"
	}
}

module "dcore-iam" {
	source           = "../../modules/iam_role/"
	aws_role_name    = "${var.aws_role_name}"
	aws_policy_name  = "${var.aws_policy_name}"
	aws_policy_rules = "${data.template_file.policy.rendered}"
	aws_profile_name = "${var.aws_profile_name}"
}

module "dcore-group-devs" {
	source = "../../modules/iam_users_groups/"
	# Create Groups(Devs) and policy
	group_name       = "devs"
	group_path       = "/devs/"
	group_policy_name= "allow_devs_access"
	group_policy     = "${file("${path.module}/../../templates/dev_policy.json")}"
	iam_username     = "developer1"
	iam_user_path    = "/developer1/"
}

module "dcore-group-testers" {
	source = "../../modules/iam_users_groups/"
	# Create Groups(Testers) and policy
	group_name       = "testers"
	group_path       = "/testers/"
	group_policy_name= "allow_testers_access"
	group_policy     = "${file("${path.module}/../../templates/tester_policy.json")}"
	iam_username     = "tester1"
	iam_user_path    = "/tester1/"
}

module "dcore-alb" {
	source                       = "../../modules/alb/"
	aws_region                   = "${var.aws_region}"
	vpc_id                       = "${data.terraform_remote_state.dev_vpc.vpc_id}"
	vpc_cidr_block               = "${data.terraform_remote_state.dev_vpc.vpc_cidr_block}"
	vpc_name                     = "${var.aws_vpc_name}"
	public_subnet_ids            = ["${data.terraform_remote_state.dev_vpc.public_subnet_ids}"]
	aws_environment              = "${var.aws_environment}"
	aws_role                     = "${var.aws_role}"
	target_group_port            = "${var.target_group_port}"
  	target_group_protocol        = "${var.target_group_protocol}"
  	internal                     = "${var.internal}"
  	target_healthcheck           = "${var.target_healthcheck}"
  	condition_field              = "${var.condition_field}"
  	condition_values             = ["${var.condition_values}"]
  	enable_stickiness            = "${var.enable_stickiness}"

  	http_listener_count          = "${var.http_listener_count}"
  	http_listener_port           = ["${var.http_listener_port}"]
  	http_listener_rule_count     = "${var.http_listener_rule_count}"

  # If you don't want to open listener 443, you will define count = 0
  	https_listener_count         = "${var.https_listener_count}"
  	https_listener_port          = ["${var.https_listener_port}"]
  	ssl_listener_certificate_arn = "${var.https_ssl_arn}"
  	https_listener_rule_count    = "${var.https_listener_rule_count}"
  	custom_security_group        = ["${var.custom_security_group}"]
}


module "dcore-asg" {
	source                   = "../../modules/asg/"
	aws_environment          = "${var.aws_environment}"
	vpc_id                   = "${data.terraform_remote_state.dev_vpc.vpc_id}"
	vpc_name                 = "${var.aws_vpc_name}"
	aws_image_id             = "${var.aws_image_id}"
	aws_key_name             = "${aws_key_pair.keypair.key_name}"
	aws_instance_type        = "${var.aws_instance_type}"
	iam_instance_profile     = "${module.dcore-iam.instance_profile_arn}"
	alb_security_group_rules = "${module.dcore-alb.alb_security_group_rules}"
	bastion_security_group_rules = "${module.bastion.bastion_sgr_id}"
	aws_userdata             = "${data.template_file.configure_app.rendered}"
	min_size                 = "${var.min_size}"
	max_size                 = "${var.max_size}"
	desired_size             = "${var.desired_size}"
	wait_for_elb_capacity    = "${var.wait_for_elb_capacity}"
	aws_scale_out            = "${var.aws_scale_out}"
	aws_scale_in             = "${var.aws_scale_in}"
	health_check_grace_period= "${var.health_check_grace_period}"
	health_check_type        = "${var.health_check_type}"
	default_cooldown         = "${var.default_cooldown}"
	protect_from_scale_in    = "${var.protect_from_scale_in}"
	termination_policies     = ["${var.termination_policies}"]
	tagName                  = "${var.tagName}"
	tagEnvironment           = "${var.tagEnvironment}"
	tagRole                  = "${var.tagRole}"
	tagApplication           = "${var.tagApplication}"
	tagSupportGroup          = "${var.tagSupportGroup}"
	tagOSVersion             = "${var.tagOSVersion}"
	tagBuilder               = "${var.tagBuilder}"
	aws_lb_target_group      = ["${module.dcore-alb.target_group_arn}"]
}

