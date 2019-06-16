provider "aws" {
  region     = "${var.aws_region}"
  version    = "~> 1.0"
}

locals {
  network_acls = {
    private_inbound_rules = [
      {
        rule_number = 90
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 91
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    private_outbound_rules = [
      {
        rule_number = 90
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound_rules = [
      {
        rule_number = 90
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 91
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 92
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 93
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound_rules = [
      {
        rule_number = 90
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

module "prod_vpc" {
  source                  = "../../modules/vpc"
  aws_environment         = "${var.aws_environment}"
  aws_vpc_name            = "${var.aws_vpc_name}"
  aws_vpc_cidr            = "${var.aws_vpc_cidr}"
  aws_availability_zones  = "${var.aws_availability_zones}"
  public_subnet_cidr_all  = "${var.public_subnet_cidr_all}"
  private_subnet_cidr_all = "${var.private_subnet_cidr_all}"
}

module "prod_vpc_nacl" {
  source                 = "../../modules/network-acl"
  aws_vpc_id             = "${module.prod_vpc.vpc_id}"
  private_subnet_ids     = "${module.prod_vpc.private_subnet_ids}"
  public_subnet_ids      = "${module.prod_vpc.public_subnet_ids}"
  private_inbound_rules  = "${concat(local.network_acls["private_inbound_rules"])}"
  private_outbound_rules = "${concat(local.network_acls["private_outbound_rules"])}"
  public_inbound_rules   = "${concat(local.network_acls["public_inbound_rules"])}"
  public_outbound_rules  = "${concat(local.network_acls["public_outbound_rules"])}"
}