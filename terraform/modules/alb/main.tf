provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.60"
}

# Resource for ALB
resource "aws_security_group" "lb_sg" {
    name        = "sgr-${var.aws_environment}-alb"
    description = "${var.aws_description}"
    vpc_id      = "${var.vpc_id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}", "${var.custom_security_group}"]
        description = "${var.aws_description}"
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}", "${var.custom_security_group}"]
        description = "${var.aws_description}"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "${var.aws_description}"
    }

    tags {
      Name          = "sgr-${var.aws_environment}-alb"
      Environment   = "${var.aws_environment}"
      ManagedBy     = "Terraform"
      Comment       = "${var.aws_description}"
    }
}
resource "random_integer" "random_integer" {
  min   = 1
  max   = 99
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.aws_role}-${replace(aws_lb.lb.arn_suffix, "/.*\\/([a-z0-9]+)$/", "$1")}-${random_integer.random_integer.result}"
  port     = "${var.target_group_port}"
  protocol = "${var.target_group_protocol}"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    path                = "${var.target_healthcheck}"
    interval            = 30
    protocol            = "${var.target_group_protocol}"
    matcher             = "200,399"
  }

  stickiness {
    type  = "lb_cookie"
    enabled = "${var.enable_stickiness}"
  }

  tags {
    Name        = "${var.aws_role}-${replace(aws_lb.lb.arn_suffix, "/.*\\/([a-z0-9]+)$/", "$1")}-${random_integer.random_integer.result}"
    Environment = "${var.aws_environment}"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create ALB
resource "aws_lb" "lb" {
  name                       = "${var.aws_environment}-${var.aws_role}"
  subnets                    = ["${var.public_subnet_ids}"]
  security_groups            = ["${aws_security_group.lb_sg.id}"]
  internal                   = "${var.internal}"
  load_balancer_type         = "application"
  enable_deletion_protection = false
  tags {
    Name        = "${var.aws_environment}-${var.aws_role}"
    Environment = "${var.aws_environment}"
    ManagedBy   = "Terraform"
  }
}

# Create Listener for HTTP
resource "aws_lb_listener" "lb_http_listener" {
  count             = "${var.http_listener_count}"
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${element(var.http_listener_port, count.index)}"
  protocol          = "HTTP"

  default_action     = {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "lb_https_listener" {
  count              = "${var.https_listener_count}"
  load_balancer_arn  = "${aws_lb.lb.arn}"
  port               = "${element(var.https_listener_port, count.index)}"
  protocol           = "HTTPS"
  ssl_policy         = "ELBSecurityPolicy-2016-08"
  certificate_arn    = "${element(var.ssl_listener_certificate_arn, count.index)}"

  default_action     = {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "http_host_route" {
  count        = "${var.http_listener_rule_count}"
  listener_arn = "${aws_lb_listener.lb_http_listener.arn}"
  priority     = "${count.index+20}"

  action {
    type       = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }

  condition {
    field  = "${var.condition_field}"
    values = ["${element(var.condition_values, count.index)}"]
  }
}

resource "aws_lb_listener_rule" "https_host_route" {
  count        = "${var.https_listener_rule_count}"
  listener_arn = "${aws_lb_listener.lb_https_listener.arn}"
  priority     = "${count.index+10}"

  action {
    type   = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }

  condition {
    field = "${var.condition_field}"
    values = ["${element(var.condition_values, count.index)}"]
  }
}