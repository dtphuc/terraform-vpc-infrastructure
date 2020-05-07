output "ec2_id" {
  value = aws_instance.this.*.id
}

output "ec2_private_ip" {
  value = aws_instance.this.*.private_ip
}

output "ec2_public_ip" {
  value = aws_instance.this.*.public_ip
}