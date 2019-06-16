data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id  = "${var.vpc_id}"
  tags {
    Name          = "${var.vpc_name}-private-*"
    Environment   = "${var.aws_environment}"
  }
}

resource "aws_security_group" "sg" {
  name = "sgr-${var.aws_environment}-${var.tagRole}"
  vpc_id = "${var.vpc_id}"
  description = "${var.aws_description}"

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "TCP"
    security_groups = ["${var.alb_security_group_rules}"]
    description = "${var.aws_description}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    security_groups = ["${var.bastion_security_group_rules}"]
    description = "${var.aws_description}"
  }

  egress {
    from_port = 40000
    to_port   = 40000
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "${var.aws_description}"
  }

  egress {
    from_port = 40001
    to_port   = 40001
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "${var.aws_description}"
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "${var.aws_description}"
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "${var.aws_description}"
  }

  tags {
    Name        = "sgr-${var.aws_environment}-${var.tagRole}"
    Environment = "${var.aws_environment}"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.tagEnvironment}-lc-"
  image_id                    = "${var.aws_image_id}"
  instance_type               = "${var.aws_instance_type}"
  key_name                    = "${var.aws_key_name}"
  security_groups             = ["${aws_security_group.sg.id}"]
  iam_instance_profile        = "${var.iam_instance_profile}"
  associate_public_ip_address = false
  user_data                   = "${var.aws_userdata}"

  lifecycle {
    create_before_destroy     = true
  }
}

resource "aws_autoscaling_group" "this" {
  # interpolate the LC into the ASG name so it always forces an update
  name                      = "${var.tagName}-asg-${aws_launch_configuration.this.name}"
  #availability_zones       = ["${data.aws_availability_zones.available.names}"]
  launch_configuration      = "${aws_launch_configuration.this.name}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.private_subnet_ids.ids}"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  desired_capacity          = "${var.desired_size}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  termination_policies      = ["${var.termination_policies}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  force_delete              = false
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  target_group_arns         = ["${var.aws_lb_target_group}"]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags {
    key                 = "Name"
    value               = "${var.tagName}"
    propagate_at_launch = true
  }

  tags {
    key                 = "Environment"
    value               = "${var.tagEnvironment}"
    propagate_at_launch = true
  }

  tags {
    key                 = "Role"
    value               = "${var.tagRole}"
    propagate_at_launch = true
  }

  tags {
    key                 = "Application"
    value               = "${var.tagApplication}"
    propagate_at_launch = true
  }

  tags {
    key                 = "SupportGroup"
    value               = "${var.tagSupportGroup}"
    propagate_at_launch = true
  }

  tags {
    key                 = "os_version"
    value               = "${var.tagOSVersion}"
    propagate_at_launch = true
  }

  tags {
    key                 = "builder"
    value               = "${var.tagBuilder}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "asg_scale_out" {
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  name                   = "${var.tagEnvironment}-${var.tagRole}-Scale-Out"
  scaling_adjustment     = "${var.aws_scale_out}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.default_cooldown}"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "asg_scale_in" {
  autoscaling_group_name = "${aws_autoscaling_group.this.name}"
  name                   = "${var.tagEnvironment}-${var.tagRole}-Scale-In"
  scaling_adjustment     = "${var.aws_scale_in}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.default_cooldown}"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_up" {
  alarm_name             = "${var.tagEnvironment}-${var.tagRole}-Alarm-ScaleOut-${var.metric_name}"
  comparison_operator    = "${var.comparison_operator_greater}"
  evaluation_periods     = "${var.evaluation_periods}"
  metric_name            = "${var.metric_name}"
  namespace              = "${var.namespace}"
  period                 = "${var.period}"
  statistic              = "${var.statistic}"
  threshold              = "${var.threshold_in}"
  dimensions {
    "AutoScalingGroupName" = "${aws_autoscaling_group.this.name}"
  }

  alarm_description      = "${var.aws_description}"
  alarm_actions          = ["${aws_autoscaling_policy.asg_scale_out.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_down" {
  alarm_name          = "${var.tagEnvironment}-${var.tagRole}-Alarm-ScaleIn-${var.metric_name}"
  comparison_operator = "${var.comparison_operator_less}"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "${var.metric_name}"
  namespace           = "${var.namespace}"
  period              = "${var.period}"
  statistic           = "${var.statistic}"
  threshold           = "${var.threshold_out}"
  dimensions {
    "AutoScalingGroupName" = "${aws_autoscaling_group.this.name}"
  }

  alarm_description   = "${var.aws_description}"
  alarm_actions       = ["${aws_autoscaling_policy.asg_scale_in.arn}"]
}
