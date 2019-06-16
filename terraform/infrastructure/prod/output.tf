# Output of AWS VPC
output "vpc_id" {
  value = "${module.prod_vpc.vpc_id}"
}

output "vpc_name" {
  value = "${module.prod_vpc.vpc_name}"
}

output "vpc_cidr_block" {
  value = "${module.prod_vpc.vpc_cidr_block}"
}

output "vpc_route_tables" {
  value = ["${module.prod_vpc.vpc_route_tables}"]
}

output "public_subnet_ids" {
  value = ["${module.prod_vpc.public_subnet_ids}"]
}

output "public_subnet_cidr_blocks" {
  value = ["${module.prod_vpc.private_subnet_cidr_blocks}"]
}

output "private_subnet_ids" {
  value = ["${module.prod_vpc.private_subnet_ids}"]
}

output "private_subnet_cidr_blocks" {
  value = ["${module.prod_vpc.private_subnet_cidr_blocks}"]
}