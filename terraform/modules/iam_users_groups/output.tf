output "group_name" {
  value = "${aws_iam_group.this.name}"
}

output "iam_username" {
  value = "${aws_iam_user.this.name}"
}