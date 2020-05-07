# Output of AWS VPC
output "vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "vpc_name" {
  value = module.dev_vpc.vpc_name
}

output "vpc_cidr_block" {
  value = module.dev_vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  value = [module.dev_vpc.public_subnet_ids]
}

output "public_subnet_cidr_blocks" {
  value = [module.dev_vpc.private_subnet_cidr_blocks]
}

output "private_subnet_ids" {
  value = [module.dev_vpc.private_subnet_ids]
}

output "private_subnet_cidr_blocks" {
  value = [module.dev_vpc.private_subnet_cidr_blocks]
}

