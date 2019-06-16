output "bastion_sgr_id" {
  value = "${aws_security_group.bastion_sgr.id}"
}

output "bastion_public_eip" {
  value = "${aws_instance.bastion_server.public_ip}"
}
