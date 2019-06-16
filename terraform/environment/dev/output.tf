output "lb_dns_name" {
  value = "${module.dcore-alb.lb_dns_name}"
}

output "lb_zone_id" {
  value = "${module.dcore-alb.lb_zone_id}"
}

output "target_group_name" {
  value = "${module.dcore-alb.target_group_name}"
}

output "bastion_public_ip" {
  value = "${module.bastion.bastion_public_eip}"
}

output "cloudwatch_logs_arn" {
  value = "${module.dcore-cloudwatch-logs.cloudwatch_logs_arn}"
}

output "s3_bucket_arn" {
  value = "${module.dcore-s3.s3_bucket_arn}"
}

output "dev_group" {
  value = "${module.dcore-group-devs.group_name}"
}

output "tester_group" {
  value = "${module.dcore-group-testers.group_name}"
}

output "dev_username" {
  value = "${module.dcore-group-devs.iam_username}"
}

output "tester_username" {
  value = "${module.dcore-group-testers.iam_username}"
}