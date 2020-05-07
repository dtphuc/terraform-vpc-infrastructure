output "lb_arn" {
  value = "${aws_lb.lb.arn}"
}

output "lb_arn_suffix" {
  value = "${aws_lb.lb.arn_suffix}"
}

output "lb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "lb_zone_id" {
  value = aws_lb.lb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.id
}

output "target_group_name" {
  value = aws_lb_target_group.target_group.name
}

output "alb_security_group_rules" {
  value = aws_security_group.lb_sg.id
}