output "instance_profile_id" {
  value = "${aws_iam_instance_profile.this.id}"
}

output "instance_profile_arn" {
  value = "${aws_iam_instance_profile.this.arn}"
}