variable "aws_vpc_id" {}
variable "private_inbound_rules" {
  description = "Private Inbound network ACLs"
  type        = "list"
}

variable "private_outbound_rules" {
  description = "Private Outbound network ACLs"
  type        = "list"
}

variable "public_inbound_rules" {
  description = "Public Inbound network ACLs"
  type        = "list"
}

variable "public_outbound_rules" {
  description = "Public Outbound network ACLs"
  type        = "list"
}

variable "private_subnet_ids" {
  type = "list"
}
variable "public_subnet_ids" {
  type = "list"
}


