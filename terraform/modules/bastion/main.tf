/*
# Create a on-demand EC2 instance in VPC public subnet
*/
resource "aws_security_group" "bastion_sgr" {
    name        = "sgr-${var.aws_environment}-${var.aws_bastion_sgr_name}"
    description = "${var.aws_description}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
        description = "${var.aws_description}"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.custom_security_rules}"]
        description = "SSH from Home"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "${var.aws_description}"
    }

    vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
    
    tags {
        Name          = "sgr-${var.aws_environment}-${var.aws_bastion_sgr_name}"
        Environment   = "${var.aws_environment}"
        Comment       = "${var.aws_description}"
    }
}

resource "aws_instance" "bastion_server" {
    ami                     = "${var.bastion_ami_id}"
    availability_zone       = "${data.aws_availability_zones.available.names[0]}"
    instance_type           = "${var.aws_instance_type}"
    key_name                = "${var.aws_key_name}"
    vpc_security_group_ids  = ["${aws_security_group.bastion_sgr.id}"]
    subnet_id               = "${var.public_subnet_id}"
    associate_public_ip_address = true
    user_data               = "${file("${path.module}/../../templates/bastion-userdata.sh.tpl")}"
    disable_api_termination = "false"

    tags {
        Name        = "${var.aws_bastion_instance_name}"
        Environment = "${var.aws_environment}"
        Comment     = "${var.aws_description}"
    }
}

resource "aws_eip" "bastion_server_eip" {
    instance = "${aws_instance.bastion_server.id}"
    vpc      = true
}
