### Private Network ACLs

resource "aws_network_acl" "private" {
  vpc_id     = "${var.aws_vpc_id}"
  subnet_ids = ["${var.private_subnet_ids}"]
}

resource "aws_network_acl" "public" {
  vpc_id     = "${var.aws_vpc_id}"
  subnet_ids = ["${var.public_subnet_ids}"]
}


resource "aws_network_acl_rule" "private_inbound_rules" {
    count          = "${length(var.private_inbound_rules)}"
    network_acl_id = "${aws_network_acl.private.id}"
    egress         = false
    rule_number    = "${lookup(var.private_inbound_rules[count.index], "rule_number")}"
    rule_action    = "${lookup(var.private_inbound_rules[count.index], "rule_action")}"
    from_port      = "${lookup(var.private_inbound_rules[count.index], "from_port")}"
    to_port        = "${lookup(var.private_inbound_rules[count.index], "to_port")}"
    protocol       = "${lookup(var.private_inbound_rules[count.index], "protocol")}"
    cidr_block     = "${lookup(var.private_inbound_rules[count.index], "cidr_block")}"   
}

resource "aws_network_acl_rule" "private_outbound_rules" {
    count          = "${length(var.private_outbound_rules)}"
    network_acl_id = "${aws_network_acl.private.id}"
    egress         = true
    rule_number    = "${lookup(var.private_outbound_rules[count.index], "rule_number")}"
    rule_action    = "${lookup(var.private_outbound_rules[count.index], "rule_action")}"
    from_port      = "${lookup(var.private_outbound_rules[count.index], "from_port")}"
    to_port        = "${lookup(var.private_outbound_rules[count.index], "to_port")}"
    protocol       = "${lookup(var.private_outbound_rules[count.index], "protocol")}"
    cidr_block     = "${lookup(var.private_outbound_rules[count.index], "cidr_block")}"    
}

resource "aws_network_acl_rule" "public_inbound_rules" {
    count          = "${length(var.public_inbound_rules)}"
    network_acl_id = "${aws_network_acl.public.id}"
    egress         = false
    rule_number    = "${lookup(var.public_inbound_rules[count.index], "rule_number")}"
    rule_action    = "${lookup(var.public_inbound_rules[count.index], "rule_action")}"
    from_port      = "${lookup(var.public_inbound_rules[count.index], "from_port")}"
    to_port        = "${lookup(var.public_inbound_rules[count.index], "to_port")}"
    protocol       = "${lookup(var.public_inbound_rules[count.index], "protocol")}"
    cidr_block     = "${lookup(var.public_inbound_rules[count.index], "cidr_block")}"   
}

resource "aws_network_acl_rule" "public_outbound_rules" {
    count          = "${length(var.public_outbound_rules)}"
    network_acl_id = "${aws_network_acl.public.id}"
    egress         = true
    rule_number    = "${lookup(var.public_outbound_rules[count.index], "rule_number")}"
    rule_action    = "${lookup(var.public_outbound_rules[count.index], "rule_action")}"
    from_port      = "${lookup(var.public_outbound_rules[count.index], "from_port")}"
    to_port        = "${lookup(var.public_outbound_rules[count.index], "to_port")}"
    protocol       = "${lookup(var.public_outbound_rules[count.index], "protocol")}"
    cidr_block     = "${lookup(var.public_outbound_rules[count.index], "cidr_block")}"    
}
