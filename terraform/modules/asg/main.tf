resource "aws_launch_configuration" "this" {
  name_prefix                 = "${var.aws_environment}-${var.tagRole}-lc-"
  image_id                    = var.aws_image_id
  instance_type               = var.aws_instance_type
  key_name                    = var.aws_key_name
  security_groups             = var.aws_security_group_id
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.aws_userdata

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  # interpolate the LC into the ASG name so it always forces an update
  name = "${var.tagName}-asg-${aws_launch_configuration.this.name}"

  #availability_zones       = ["${data.aws_availability_zones.available.names}"]
  launch_configuration      = aws_launch_configuration.this.name
  vpc_zone_identifier       = var.vpc_zone_identifier
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_size
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  termination_policies      = var.termination_policies
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  force_delete              = false
  protect_from_scale_in     = var.protect_from_scale_in
  target_group_arns         = var.aws_lb_target_group

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

  tags = [
    {
      key                 = "Name"
      value               = var.tagName
      propagate_at_launch = true
    },

    {
      key                 = "Environment"
      value               = var.tagEnvironment
      propagate_at_launch = true
    },

    {
      key                 = "Role"
      value               = var.tagRole
      propagate_at_launch = true
    },

    {
      key                 = "Application"
      value               = var.tagApplication
      propagate_at_launch = true
    },

    {
      key                 = "SupportGroup"
      value               = var.tagSupportGroup
      propagate_at_launch = true
    },

    {
      key                 = "OS Version"
      value               = var.tagOSVersion
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "asg_scale_out" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name                   = "${var.tagEnvironment}-${var.tagRole}-Scale-Out"
  scaling_adjustment     = var.aws_scale_out
  adjustment_type        = var.adjustment_type
  cooldown               = var.default_cooldown
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "asg_scale_in" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name                   = "${var.tagEnvironment}-${var.tagRole}-Scale-In"
  scaling_adjustment     = var.aws_scale_in
  adjustment_type        = var.adjustment_type
  cooldown               = var.default_cooldown
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_up" {
  alarm_name          = "${var.tagEnvironment}-${var.tagRole}-Alarm-ScaleOut-${var.metric_name}"
  comparison_operator = var.comparison_operator_greater
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold_in
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }

  alarm_description = var.aws_description
  alarm_actions     = [aws_autoscaling_policy.asg_scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_down" {
  alarm_name          = "${var.tagEnvironment}-${var.tagRole}-Alarm-ScaleIn-${var.metric_name}"
  comparison_operator = var.comparison_operator_less
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold_out
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }

  alarm_description = var.aws_description
  alarm_actions     = [aws_autoscaling_policy.asg_scale_in.arn]
}

