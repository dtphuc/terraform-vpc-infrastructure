output "lb_dns_name" {
  value = module.alb.lb_dns_name
}

output "lb_zone_id" {
  value = module.alb.lb_zone_id
}

output "target_group_name" {
  value = module.alb.target_group_name
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_eip
}